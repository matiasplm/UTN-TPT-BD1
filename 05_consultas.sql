-- ============================================================
-- ETAPA 3 - CONSULTAS Y MEDICIONES DE RENDIMIENTO
-- Trabajo Final Integrador - Bases de Datos I
-- ============================================================

USE tp_integrador_bd1;   -- Selecciona la base de datos principal del proyecto

-- ============================================================
-- 1️. TABLA DE MEDICIONES (idempotente)
-- ------------------------------------------------------------
-- Esta tabla guarda los tiempos medidos para cada consulta,
-- diferenciando las versiones SIN índice y CON índice.
-- Se usa un diseño simple con fecha de ejecución para trazabilidad.
-- ============================================================

DROP TABLE IF EXISTS mediciones;
CREATE TABLE mediciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    consulta VARCHAR(40),            -- Identificador de la consulta (ej: Q1_IGUALDAD)
    corrida TINYINT,                 -- Número de ejecución (permite varias corridas)
    tiempo_us BIGINT,                -- Tiempo medido en microsegundos
    variante ENUM('SIN_IDX','CON_IDX'), -- Variante de la prueba
    fecha_ejec DATETIME DEFAULT NOW()   -- Fecha y hora del test
);

-- ============================================================
-- 2️. CONSULTA Q1 - Igualdad (búsqueda puntual por DNI)
-- ------------------------------------------------------------
-- Objetivo: medir el impacto de un índice sobre búsquedas exactas.
-- Hipótesis: el índice en 'dni' mejora radicalmente el rendimiento
-- al evitar escanear toda la tabla de clientes.
-- ============================================================

SET @dni_busqueda = '10009998';  -- Valor buscado (existente en los datos generados)

-- === Variante SIN ÍNDICE ===
-- Se ignora cualquier índice explícito para simular un escaneo completo.
SET @sql := '
SELECT  c.id_cliente, c.nombre, c.apellido, p.email, COUNT(v.id_venta) AS cant_ventas
FROM clientes c
JOIN perfiles_clientes p ON p.id_cliente = c.id_cliente
LEFT JOIN ventas v ON v.id_cliente = c.id_cliente
WHERE c.dni = ?
GROUP BY c.id_cliente, c.nombre, c.apellido, p.email;
';

-- Medición temporal y ejecución dinámica
PREPARE q FROM @sql;
SET @t0 = NOW(6);                    -- Inicio de medición (microsegundos)
EXECUTE q USING @dni_busqueda;       -- Ejecución de la consulta
SET @t1 = NOW(6);                    -- Fin de medición
INSERT INTO mediciones VALUES (NULL, "Q1_IGUALDAD", 1,
       TIMESTAMPDIFF(MICROSECOND,@t0,@t1),"SIN_IDX",NOW());
DEALLOCATE PREPARE q;

-- === Variante CON ÍNDICE ===
-- Se fuerza el uso del índice idx_clientes_dni.
SET @sql := '
SELECT  c.id_cliente, c.nombre, c.apellido, p.email, COUNT(v.id_venta) AS cant_ventas
FROM clientes c FORCE INDEX (idx_clientes_dni)
JOIN perfiles_clientes p ON p.id_cliente = c.id_cliente
LEFT JOIN ventas v ON v.id_cliente = c.id_cliente
WHERE c.dni = ?
GROUP BY c.id_cliente, c.nombre, c.apellido, p.email;
';
PREPARE q FROM @sql;
SET @t0 = NOW(6);
EXECUTE q USING @dni_busqueda;
SET @t1 = NOW(6);
INSERT INTO mediciones VALUES (NULL, "Q1_IGUALDAD", 1,
       TIMESTAMPDIFF(MICROSECOND,@t0,@t1),"CON_IDX",NOW());
DEALLOCATE PREPARE q;

-- ============================================================
-- 3️. CONSULTA Q2 - Rango temporal (ventas por trimestre)
-- ------------------------------------------------------------
-- Objetivo: comparar el rendimiento en búsquedas por intervalo de fechas.
-- Hipótesis: un índice en 'fecha' reduce significativamente el tiempo
-- de escaneo para consultas por períodos específicos.
-- ============================================================

SET @fini = '2025-01-01';
SET @ffin = '2025-03-31';

-- === SIN ÍNDICE ===
SET @sql := '
SELECT v.id_cliente, c.nombre, c.apellido,
       COUNT(*) AS cantidad_ventas, ROUND(SUM(v.total),2) AS total_ventas
FROM ventas v IGNORE INDEX (idx_ventas_fecha)
JOIN clientes c ON c.id_cliente = v.id_cliente
WHERE v.fecha BETWEEN ? AND ?
GROUP BY v.id_cliente, c.nombre, c.apellido
ORDER BY total_ventas DESC
LIMIT 10;
';
PREPARE q FROM @sql;
SET @t0 = NOW(6);
EXECUTE q USING @fini, @ffin;
SET @t1 = NOW(6);
INSERT INTO mediciones VALUES (NULL,"Q2_RANGO",1,
       TIMESTAMPDIFF(MICROSECOND,@t0,@t1),"SIN_IDX",NOW());
DEALLOCATE PREPARE q;

-- === CON ÍNDICE ===
-- Fuerza el uso del índice en la columna 'fecha'.
SET @sql := '
SELECT v.id_cliente, c.nombre, c.apellido,
       COUNT(*) AS cantidad_ventas, ROUND(SUM(v.total),2) AS total_ventas
FROM ventas v FORCE INDEX (idx_ventas_fecha)
JOIN clientes c ON c.id_cliente = v.id_cliente
WHERE v.fecha BETWEEN ? AND ?
GROUP BY v.id_cliente, c.nombre, c.apellido
ORDER BY total_ventas DESC
LIMIT 10;
';
PREPARE q FROM @sql;
SET @t0 = NOW(6);
EXECUTE q USING @fini, @ffin;
SET @t1 = NOW(6);
INSERT INTO mediciones VALUES (NULL,"Q2_RANGO",1,
       TIMESTAMPDIFF(MICROSECOND,@t0,@t1),"CON_IDX",NOW());
DEALLOCATE PREPARE q;

-- ============================================================
-- 4️. CONSULTA Q3 - JOIN múltiple + LIKE + estado
-- ------------------------------------------------------------
-- Objetivo: evaluar la diferencia de rendimiento en consultas complejas
-- con múltiples joins, condiciones combinadas y filtros por texto.
-- Hipótesis: índices compuestos en (fecha, estado) y simples en (nombre)
-- mejoran sustancialmente las búsquedas de este tipo.
-- ============================================================

SET @pref = 'Cliente 1%';
SET @desde = '2024-06-01';
SET @hasta = '2025-06-30';

-- === SIN ÍNDICE ===
SET @sql := '
SELECT  c.id_cliente, c.nombre, c.apellido, p.email,
        COUNT(v.id_venta) AS total_ventas,
        ROUND(SUM(v.total),2) AS monto_total,
        ROUND(AVG(v.total),2) AS ticket_promedio
FROM clientes c
JOIN perfiles_clientes p ON p.id_cliente = c.id_cliente
JOIN ventas v IGNORE INDEX (idx_ventas_fecha_estado)
     ON v.id_cliente = c.id_cliente
WHERE c.nombre LIKE ?
  AND v.fecha BETWEEN ? AND ?
  AND v.estado = "PAGADA"
GROUP BY c.id_cliente, c.nombre, c.apellido, p.email
ORDER BY monto_total DESC
LIMIT 15;
';
PREPARE q FROM @sql;
SET @t0 = NOW(6);
EXECUTE q USING @pref,@desde,@hasta;
SET @t1 = NOW(6);
INSERT INTO mediciones VALUES (NULL,"Q3_JOIN",1,
       TIMESTAMPDIFF(MICROSECOND,@t0,@t1),"SIN_IDX",NOW());
DEALLOCATE PREPARE q;

-- === CON ÍNDICE ===
-- Se aprovechan los índices compuestos y por nombre.
SET @sql := '
SELECT  c.id_cliente, c.nombre, c.apellido, p.email,
        COUNT(v.id_venta) AS total_ventas,
        ROUND(SUM(v.total),2) AS monto_total,
        ROUND(AVG(v.total),2) AS ticket_promedio
FROM clientes c FORCE INDEX (idx_clientes_nombre)
JOIN perfiles_clientes p ON p.id_cliente = c.id_cliente
JOIN ventas v FORCE INDEX (idx_ventas_fecha_estado)
     ON v.id_cliente = c.id_cliente
WHERE c.nombre LIKE ?
  AND v.fecha BETWEEN ? AND ?
  AND v.estado = "PAGADA"
GROUP BY c.id_cliente, c.nombre, c.apellido, p.email
ORDER BY monto_total DESC
LIMIT 15;
';
PREPARE q FROM @sql;
SET @t0 = NOW(6);
EXECUTE q USING @pref,@desde,@hasta;
SET @t1 = NOW(6);
INSERT INTO mediciones VALUES (NULL,"Q3_JOIN",1,
       TIMESTAMPDIFF(MICROSECOND,@t0,@t1),"CON_IDX",NOW());
DEALLOCATE PREPARE q;

-- ============================================================
-- 5️. CONSULTA Q4 - Subconsulta (clientes con total > promedio)
-- ------------------------------------------------------------
-- Objetivo: aplicar subconsultas anidadas con agregación.
-- Hipótesis: aunque no se mida rendimiento, la subconsulta ilustra
-- un caso analítico real (ranking de clientes sobre el promedio).
-- ============================================================

SELECT c.id_cliente, c.nombre, c.apellido, t.total_2025
FROM clientes c
JOIN (
    SELECT v.id_cliente, SUM(v.total) AS total_2025
    FROM ventas v
    WHERE v.fecha BETWEEN '2025-01-01' AND '2025-12-31'
    GROUP BY v.id_cliente
) t ON t.id_cliente = c.id_cliente
WHERE t.total_2025 > (
    SELECT AVG(x.suma) FROM (
        SELECT SUM(v2.total) AS suma
        FROM ventas v2
        WHERE v2.fecha BETWEEN '2025-01-01' AND '2025-12-31'
        GROUP BY v2.id_cliente
    ) x
)
ORDER BY t.total_2025 DESC
LIMIT 20;

-- ============================================================
-- 6️. REPORTE FINAL DE MEDIANAS Y MEJORA %
-- ------------------------------------------------------------
-- Objetivo: generar una tabla resumen con tiempos sin/con índice
-- y el porcentaje de mejora. Si solo hay una corrida, la mediana
-- coincide con el valor único.
-- ============================================================

SELECT
  consulta,
  MAX(CASE WHEN variante='SIN_IDX' THEN tiempo_us END) AS tiempo_sin_idx,
  MAX(CASE WHEN variante='CON_IDX' THEN tiempo_us END) AS tiempo_con_idx,
  ROUND(
    (MAX(CASE WHEN variante='SIN_IDX' THEN tiempo_us END)
     - MAX(CASE WHEN variante='CON_IDX' THEN tiempo_us END))
     / NULLIF(MAX(CASE WHEN variante='SIN_IDX' THEN tiempo_us END),0) * 100, 2
  ) AS mejora_pct
FROM mediciones
GROUP BY consulta
ORDER BY consulta;

-- ============================================================
-- 7️. VERIFICACIÓN FINAL
-- ------------------------------------------------------------
-- Muestra todas las mediciones registradas para confirmar
-- que cada consulta fue medida en ambas variantes.
-- ============================================================

SELECT * FROM mediciones ORDER BY consulta, variante;
