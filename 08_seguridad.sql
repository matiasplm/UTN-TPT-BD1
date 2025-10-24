USE tp_integrador_bd1;

-- Crear usuario con privilegios mínimos
DROP USER IF EXISTS 'usuario_tpi'@'localhost';
CREATE USER 'usuario_tpi'@'localhost' IDENTIFIED BY 'tpi_seguro2025';
GRANT SELECT, INSERT, UPDATE ON tp_integrador_bd1.* TO 'usuario_tpi'@'localhost';
FLUSH PRIVILEGES;

-- Vistas seguras (ocultan datos sensibles)
DROP VIEW IF EXISTS vw_clientes_publicos;
CREATE VIEW vw_clientes_publicos AS
SELECT id_cliente, nombre, apellido, email, fecha_alta
FROM clientes
JOIN perfiles_clientes USING (id_cliente);

DROP VIEW IF EXISTS vw_resumen_ventas_publico;
CREATE VIEW vw_resumen_ventas_publico AS
SELECT
    v.id_cliente,
    COUNT(v.id_venta) AS cantidad,
    ROUND(SUM(v.total),2) AS total,
    MAX(v.fecha) AS ultima_venta
FROM ventas v
GROUP BY v.id_cliente;

-- Pruebas de integridad
-- Violación UNIQUE
INSERT INTO clientes (dni, nombre, apellido) VALUES ('12345678','Duplicado','Test');

-- Violación FK
INSERT INTO ventas (id_cliente, fecha, total, estado) 
VALUES (999999,'2025-10-01',1000.00,'PAGADA');

-- Violación CHECK total
INSERT INTO ventas (id_cliente, fecha, total, estado)
SELECT id_cliente,'2025-10-01',-200.00,'PAGADA' FROM clientes LIMIT 1;

-- Violación CHECK estado
INSERT INTO ventas (id_cliente, fecha, total, estado)
SELECT id_cliente,'2025-10-01',100.00,'ERROR' FROM clientes LIMIT 1;