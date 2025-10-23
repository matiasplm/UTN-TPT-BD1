/* ============================================================
   04_indices.sql
   Etapa 3 - Índices y optimización
   ============================================================ */

USE tp_integrador_bd1;   -- Selecciona la base de datos del trabajo integrador

-- ============================================================
-- 1️ LIMPIEZA SEGURA DE ÍNDICES EXISTENTES
-- ------------------------------------------------------------
-- Este bloque elimina los índices previos solo si existen.
-- Usa SQL dinámico para evitar errores si alguno no está presente.
-- ============================================================

SET @sql = (
  SELECT GROUP_CONCAT(CONCAT('DROP INDEX ', INDEX_NAME, ' ON ', TABLE_NAME, ';') SEPARATOR '\n')
  FROM information_schema.STATISTICS
  WHERE TABLE_SCHEMA = DATABASE()
    AND INDEX_NAME IN (
      'idx_clientes_dni','idx_clientes_nombre',
      'idx_ventas_fecha','idx_ventas_fecha_estado',
      'idx_ventas_cliente_fecha','ix_ventas_fecha_cliente'
    )
);

-- Si no hay índices que eliminar, genera un mensaje informativo
SET @sql = IFNULL(@sql, 'SELECT "No hay índices que eliminar" AS info;');

-- Ejecuta el SQL generado dinámicamente
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================
-- 2️ CREACIÓN DE ÍNDICES (con verificación previa)
-- ------------------------------------------------------------
-- Cada bloque:
--  - Verifica si el índice ya existe.
--  - Si no, lo crea.
--  - Si sí existe, muestra un mensaje informativo.
-- Este patrón garantiza idempotencia y evita errores.
-- ============================================================

-- Índice 1: acelera búsquedas por DNI (igualdad)
SELECT COUNT(*) INTO @existe FROM information_schema.STATISTICS 
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME='clientes' AND INDEX_NAME='idx_clientes_dni';
SET @sql = IF(@existe=0, 'CREATE INDEX idx_clientes_dni ON clientes (dni);', 'SELECT "idx_clientes_dni ya existe" AS info;');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Índice 2: optimiza consultas por patrón de nombre (LIKE 'Cliente 1%')
SELECT COUNT(*) INTO @existe FROM information_schema.STATISTICS 
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME='clientes' AND INDEX_NAME='idx_clientes_nombre';
SET @sql = IF(@existe=0, 'CREATE INDEX idx_clientes_nombre ON clientes (nombre);', 'SELECT "idx_clientes_nombre ya existe" AS info;');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Índice 3: mejora consultas por rango de fechas (BETWEEN)
SELECT COUNT(*) INTO @existe FROM information_schema.STATISTICS 
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME='ventas' AND INDEX_NAME='idx_ventas_fecha';
SET @sql = IF(@existe=0, 'CREATE INDEX idx_ventas_fecha ON ventas (fecha);', 'SELECT "idx_ventas_fecha ya existe" AS info;');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Índice 4: índice compuesto que acelera filtros combinados por fecha + estado
SELECT COUNT(*) INTO @existe FROM information_schema.STATISTICS 
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME='ventas' AND INDEX_NAME='idx_ventas_fecha_estado';
SET @sql = IF(@existe=0, 'CREATE INDEX idx_ventas_fecha_estado ON ventas (fecha, estado);', 'SELECT "idx_ventas_fecha_estado ya existe" AS info;');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Índice 5: facilita JOIN y agrupamientos por cliente dentro de períodos
SELECT COUNT(*) INTO @existe FROM information_schema.STATISTICS 
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME='ventas' AND INDEX_NAME='idx_ventas_cliente_fecha';
SET @sql = IF(@existe=0, 'CREATE INDEX idx_ventas_cliente_fecha ON ventas (id_cliente, fecha);', 'SELECT "idx_ventas_cliente_fecha ya existe" AS info;');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Índice 6: variante invertida de las columnas (fecha, id_cliente)
-- útil para otras combinaciones o pruebas comparativas de orden
SELECT COUNT(*) INTO @existe FROM information_schema.STATISTICS 
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME='ventas' AND INDEX_NAME='ix_ventas_fecha_cliente';
SET @sql = IF(@existe=0, 'CREATE INDEX ix_ventas_fecha_cliente ON ventas (fecha, id_cliente);', 'SELECT "ix_ventas_fecha_cliente ya existe" AS info;');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- ============================================================
-- 3️ VERIFICACIÓN FINAL
-- ------------------------------------------------------------
-- Este reporte muestra todos los índices creados con:
--  - Nombre de tabla
--  - Nombre del índice
--  - Columnas incluidas en el índice
--  - Si permite duplicados (NON_UNIQUE)
--  - Tipo de índice (BTREE, FULLTEXT, etc.)
-- ============================================================

SELECT 
    TABLE_NAME   AS tabla,
    INDEX_NAME   AS indice,
    GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS columnas,
    NON_UNIQUE,
    INDEX_TYPE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
  AND INDEX_NAME IN (
    'idx_clientes_dni','idx_clientes_nombre',
    'idx_ventas_fecha','idx_ventas_fecha_estado',
    'idx_ventas_cliente_fecha','ix_ventas_fecha_cliente'
  )
GROUP BY TABLE_NAME, INDEX_NAME, NON_UNIQUE, INDEX_TYPE
ORDER BY tabla, indice;

-- ============================================================
-- FIN DEL SCRIPT
-- ------------------------------------------------------------
-- En este punto la base de datos queda optimizada para las
-- mediciones de rendimiento de la Etapa 3 (consultas Q1–Q3).
-- ============================================================
