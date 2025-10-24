USE tp_integrador_bd1;

-- Script para simular deadlock (ejecutar en dos sesiones diferentes)

-- SESIÓN A:
START TRANSACTION;
UPDATE cuentas SET saldo = saldo - 100 WHERE id_cuenta = 1;

-- SESIÓN B:
START TRANSACTION;
UPDATE cuentas SET saldo = saldo + 100 WHERE id_cuenta = 2;

-- SESIÓN A (después de que B ejecute su primer UPDATE):
UPDATE cuentas SET saldo = saldo + 100 WHERE id_cuenta = 2;

-- SESIÓN B (después de que A ejecute su segundo UPDATE):
UPDATE cuentas SET saldo = saldo - 100 WHERE id_cuenta = 1;

-- Comando para ver deadlocks (ejecutar después del error):
-- SHOW ENGINE INNODB STATUS\G;

-- Pruebas de niveles de aislamiento
-- SESIÓN A (REPEATABLE READ):
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT COUNT(*) AS c1 FROM ventas WHERE fecha BETWEEN '2025-01-01' AND '2025-12-31';
-- No hacer COMMIT todavía

-- SESIÓN B (insertar nueva venta):
INSERT INTO ventas (id_cliente, fecha, total, estado)
SELECT id_cliente, '2025-07-15', 12345.67, 'PAGADA'
FROM clientes ORDER BY id_cliente LIMIT 1;

-- SESIÓN A (misma transacción):
SELECT COUNT(*) AS c2 FROM ventas WHERE fecha BETWEEN '2025-01-01' AND '2025-12-31';
COMMIT;

-- Repetir con READ COMMITTED:
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT COUNT(*) AS c1 FROM ventas WHERE fecha BETWEEN '2025-01-01' AND '2025-12-31';
-- SESIÓN B inserta igual
SELECT COUNT(*) AS c2 FROM ventas WHERE fecha BETWEEN '2025-01-01' AND '2025-12-31';
COMMIT;