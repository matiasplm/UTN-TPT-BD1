/* ============================================================
   05_01_explain.sql
   Etapa 3 – Planes de ejecución y uso de índices
   Proyecto: Trabajo Final Integrador - Bases de Datos I
   Compatible con MySQL 8.x y 9.x
   ============================================================ */

-- Se utiliza la base de datos principal del proyecto
USE tp_integrador_bd1;

-- ============================================================
-- Q1: Igualdad por DNI (tabla clientes)
-- Objetivo: comparar rendimiento al buscar un cliente puntual 
--           usando o no el índice 'idx_clientes_dni'.
-- ============================================================

-- 🔸 Versión SIN ÍNDICE:
-- IGNORE INDEX indica al optimizador que ignore el índice definido.
-- Esto fuerza un escaneo completo (Full Table Scan) sobre la tabla clientes.
EXPLAIN ANALYZE
SELECT  c.id_cliente, c.nombre, c.apellido, p.email, COUNT(v.id_venta) AS cant_ventas
FROM clientes c IGNORE INDEX (idx_clientes_dni)
JOIN perfiles_clientes p ON p.id_cliente = c.id_cliente
LEFT JOIN ventas v ON v.id_cliente = c.id_cliente
WHERE c.dni = '10009998'
GROUP BY c.id_cliente, c.nombre, c.apellido, p.email;

-- 🔹 Versión CON ÍNDICE:
-- FORCE INDEX obliga al optimizador a utilizar el índice especificado.
-- En este caso, MySQL usará un Index Lookup para ubicar al cliente exacto.
EXPLAIN ANALYZE
SELECT  c.id_cliente, c.nombre, c.apellido, p.email, COUNT(v.id_venta) AS cant_ventas
FROM clientes c FORCE INDEX (idx_clientes_dni)
JOIN perfiles_clientes p ON p.id_cliente = c.id_cliente
LEFT JOIN ventas v ON v.id_cliente = c.id_cliente
WHERE c.dni = '10009998'
GROUP BY c.id_cliente, c.nombre, c.apellido, p.email;

-- Esperado:
--  - SIN índice → "Table scan on clientes"
--  - CON índice → "Index lookup on clientes using idx_clientes_dni"


-- ============================================================
-- Q2: Rango temporal por fecha (tabla ventas)
-- Objetivo: evaluar el índice 'idx_ventas_fecha' sobre consultas
--           de rango de fechas.
-- ============================================================

-- 🔸 Versión SIN ÍNDICE:
-- Se ignora el índice y se fuerza un escaneo completo de ventas.
EXPLAIN ANALYZE
SELECT v.id_cliente, c.nombre, c.apellido,
       COUNT(*) AS cantidad_ventas, ROUND(SUM(v.total),2) AS total_ventas
FROM ventas v IGNORE INDEX (idx_ventas_fecha)
JOIN clientes c ON c.id_cliente = v.id_cliente
WHERE v.fecha BETWEEN '2025-01-01' AND '2025-03-31'
GROUP BY v.id_cliente, c.nombre, c.apellido
ORDER BY total_ventas DESC
LIMIT 10;

-- 🔹 Versión CON ÍNDICE:
-- Se fuerza el uso de 'idx_ventas_fecha', que permite hacer
-- un Index Range Scan entre los límites de fecha indicados.
EXPLAIN ANALYZE
SELECT v.id_cliente, c.nombre, c.apellido,
       COUNT(*) AS cantidad_ventas, ROUND(SUM(v.total),2) AS total_ventas
FROM ventas v FORCE INDEX (idx_ventas_fecha)
JOIN clientes c ON c.id_cliente = v.id_cliente
WHERE v.fecha BETWEEN '2025-01-01' AND '2025-03-31'
GROUP BY v.id_cliente, c.nombre, c.apellido
ORDER BY total_ventas DESC
LIMIT 10;

-- Esperado:
--  - SIN índice → "Table scan on ventas"
--  - CON índice → "Index range scan on ventas using idx_ventas_fecha"


-- ============================================================
-- Q3: JOIN + LIKE + Estado (clientes + ventas)
-- Objetivo: comprobar cómo los índices compuestos ayudan en 
--           consultas con múltiples filtros y condiciones.
-- Índices usados:
--   - idx_clientes_nombre  → para el LIKE 'Cliente 1%'
--   - idx_ventas_fecha_estado → para fecha y estado simultáneamente
-- ============================================================

-- 🔸 Versión SIN ÍNDICES:
-- Se ignoran ambos índices, provocando full scans sobre clientes y ventas.
EXPLAIN ANALYZE
SELECT  c.id_cliente, c.nombre, c.apellido, p.email,
        COUNT(v.id_venta) AS total_ventas,
        ROUND(SUM(v.total),2) AS monto_total
FROM clientes c IGNORE INDEX (idx_clientes_nombre)
JOIN perfiles_clientes p ON p.id_cliente = c.id_cliente
JOIN ventas v IGNORE INDEX (idx_ventas_fecha_estado) ON v.id_cliente = c.id_cliente
WHERE c.nombre LIKE 'Cliente 1%'
  AND v.fecha BETWEEN '2024-06-01' AND '2025-06-30'
  AND v.estado = 'PAGADA'
GROUP BY c.id_cliente, c.nombre, c.apellido, p.email
ORDER BY monto_total DESC
LIMIT 15;

-- 🔹 Versión CON ÍNDICES:
-- Se obliga al uso de los índices definidos para nombre y (fecha, estado).
-- Esto permite al motor reducir el conjunto de filas antes del JOIN.
EXPLAIN ANALYZE
SELECT  c.id_cliente, c.nombre, c.apellido, p.email,
        COUNT(v.id_venta) AS total_ventas,
        ROUND(SUM(v.total),2) AS monto_total
FROM clientes c FORCE INDEX (idx_clientes_nombre)
JOIN perfiles_clientes p ON p.id_cliente = c.id_cliente
JOIN ventas v FORCE INDEX (idx_ventas_fecha_estado) ON v.id_cliente = c.id_cliente
WHERE c.nombre LIKE 'Cliente 1%'
  AND v.fecha BETWEEN '2024-06-01' AND '2025-06-30'
  AND v.estado = 'PAGADA'
GROUP BY c.id_cliente, c.nombre, c.apellido, p.email
ORDER BY monto_total DESC
LIMIT 15;

-- Esperado:
--  - SIN índices → "Table scan on clientes" y "Table scan on ventas"
--  - CON índices → "Index range scan on clientes using idx_clientes_nombre"
--                   y "Index range scan on ventas using idx_ventas_fecha_estado"
-- El plan debe mostrar también "Index condition: (LIKE 'Cliente 1%')" y 
-- "Index condition: (estado='PAGADA' and fecha between ...)" indicando
-- Index Condition Pushdown (optimización del filtrado).

-- ============================================================
-- ✅ FIN DEL SCRIPT
-- Este script no altera datos. Se usa únicamente para obtener 
-- y comparar los planes de ejecución generados por el optimizador.
-- ============================================================
