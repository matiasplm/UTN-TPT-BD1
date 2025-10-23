USE tp_integrador_bd1;

-- Vista útil para reportes
DROP VIEW IF EXISTS vw_resumen_ventas_2025;
CREATE VIEW vw_resumen_ventas_2025 AS
SELECT
    c.id_cliente,
    c.nombre,
    c.apellido,
    p.email,
    COUNT(v.id_venta) AS cant_ventas,
    ROUND(SUM(v.total), 2) AS total_ventas,
    ROUND(AVG(v.total), 2) AS ticket_promedio,
    MIN(v.fecha) AS primera_compra_2025,
    MAX(v.fecha) AS ultima_compra_2025
FROM clientes c
JOIN perfiles_clientes p ON p.id_cliente = c.id_cliente
LEFT JOIN ventas v ON v.id_cliente = c.id_cliente
    AND v.fecha BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY c.id_cliente, c.nombre, c.apellido, p.email;

-- Chequeo de la vista
SELECT * FROM vw_resumen_ventas_2025 ORDER BY total_ventas DESC LIMIT 20;