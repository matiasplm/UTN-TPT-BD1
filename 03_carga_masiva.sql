/* ============================================================
   03_carga_masiva.sql
   Etapa 2 - Carga masiva de datos (versión corregida y optimizada)
   Proyecto: Trabajo Final Integrador - Bases de Datos I
   ============================================================ */

USE tp_integrador_bd1;

-- ============================================================
-- LIMPIEZA PREVIA (mantiene estructura, resetea datos)
-- ============================================================
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE ventas;
TRUNCATE TABLE perfiles_clientes;
TRUNCATE TABLE clientes;
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- TABLAS TEMPORALES AUXILIARES PARA GENERAR SERIES NUMÉRICAS
-- ============================================================
-- Base de 10 dígitos (0–9)
DROP TEMPORARY TABLE IF EXISTS t_dig;
CREATE TEMPORARY TABLE t_dig (n INT);
INSERT INTO t_dig VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9);

-- Copias auxiliares (para combinaciones 10⁴ = 10 000)
DROP TEMPORARY TABLE IF EXISTS t_dig_a;
DROP TEMPORARY TABLE IF EXISTS t_dig_b;
DROP TEMPORARY TABLE IF EXISTS t_dig_c;
DROP TEMPORARY TABLE IF EXISTS t_dig_d;

CREATE TEMPORARY TABLE t_dig_a AS SELECT * FROM t_dig;
CREATE TEMPORARY TABLE t_dig_b AS SELECT * FROM t_dig;
CREATE TEMPORARY TABLE t_dig_c AS SELECT * FROM t_dig;
CREATE TEMPORARY TABLE t_dig_d AS SELECT * FROM t_dig;

-- ============================================================
-- CARGA DE CLIENTES (10 000 registros ÚNICOS)
-- ============================================================
-- Generamos números secuenciales del 1 al 10.000 combinando los 4 dígitos.
-- El DNI se construye de forma determinística (sin RAND) para evitar duplicados.

INSERT INTO clientes (dni, nombre, apellido, fecha_alta)
SELECT
  LPAD(10000000 + (a.n*1000 + b.n*100 + c.n*10 + d.n), 8, '0') AS dni,  -- 8 dígitos únicos
  CONCAT('Cliente ', LPAD((a.n*1000 + b.n*100 + c.n*10 + d.n + 1), 5, '0')) AS nombre,
  CONCAT('Apellido ', LPAD((a.n*1000 + b.n*100 + c.n*10 + d.n + 1), 5, '0')) AS apellido,
  DATE_ADD('2024-01-01', INTERVAL FLOOR(RAND()*365) DAY) AS fecha_alta
FROM t_dig_a a
CROSS JOIN t_dig_b b
CROSS JOIN t_dig_c c
CROSS JOIN t_dig_d d
LIMIT 10000;

SELECT COUNT(*) AS clientes_cargados FROM clientes;

-- ============================================================
-- CARGA DE PERFILES DE CLIENTES (1 a 1 con CLIENTES)
-- ============================================================
-- Se emparejan en el mismo orden de inserción, asegurando correspondencia 1:1.
SET @rownum := 0;
INSERT INTO perfiles_clientes (id_cliente, email, telefono)
SELECT
  c.id_cliente,
  CONCAT('cliente', LPAD(@rownum:=@rownum+1,5,'0'), '@mail.com') AS email,
  CONCAT('11', LPAD(FLOOR(RAND()*100000000), 8, '0')) AS telefono
FROM clientes c
ORDER BY c.id_cliente;

SELECT COUNT(*) AS perfiles_cargados FROM perfiles_clientes;

-- ============================================================
-- CARGA DE VENTAS (50 000 registros)
-- ============================================================
-- Generamos 50.000 combinaciones pseudoaleatorias de clientes y fechas válidas.
-- Cada venta apunta a un cliente existente y tiene estado coherente.

DROP TEMPORARY TABLE IF EXISTS t_dig_e;
CREATE TEMPORARY TABLE t_dig_e AS SELECT * FROM t_dig;

INSERT INTO ventas (id_cliente, fecha, total, estado)
SELECT
  FLOOR(1 + RAND() * (SELECT COUNT(*) FROM clientes)) AS id_cliente,
  DATE_ADD('2024-01-01', INTERVAL FLOOR(RAND()*730) DAY) AS fecha,
  ROUND(100 + RAND()*4900, 2) AS total,
  ELT(FLOOR(RAND()*3)+1, 'PENDIENTE','PAGADA','CANCELADA') AS estado
FROM t_dig_a a
CROSS JOIN t_dig_b b
CROSS JOIN t_dig_c c
CROSS JOIN t_dig_d d
CROSS JOIN t_dig_e e
LIMIT 50000;

SELECT COUNT(*) AS ventas_cargadas FROM ventas;

-- ============================================================
-- LIMPIEZA DE TABLAS TEMPORALES
-- ============================================================
DROP TEMPORARY TABLE IF EXISTS t_dig_e;
DROP TEMPORARY TABLE IF EXISTS t_dig_d;
DROP TEMPORARY TABLE IF EXISTS t_dig_c;
DROP TEMPORARY TABLE IF EXISTS t_dig_b;
DROP TEMPORARY TABLE IF EXISTS t_dig_a;
DROP TEMPORARY TABLE IF EXISTS t_dig;

-- ============================================================
-- VERIFICACIONES FINALES
-- ============================================================
SELECT
  (SELECT COUNT(*) FROM clientes)          AS total_clientes,
  (SELECT COUNT(*) FROM perfiles_clientes) AS total_perfiles,
  (SELECT COUNT(*) FROM ventas)            AS total_ventas;

SELECT
  estado,
  COUNT(*) AS cantidad,
  ROUND(AVG(total),2) AS promedio
FROM ventas
GROUP BY estado;

-- ============================================================
-- FIN DE SCRIPT
-- ============================================================
