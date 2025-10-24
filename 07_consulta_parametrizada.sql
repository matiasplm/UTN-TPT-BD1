USE tp_integrador_bd1;
DELIMITER //
CREATE PROCEDURE sp_buscar_cliente (IN p_dni CHAR(8))
BEGIN
	SELECT id_cliente, nombre, apellido, fecha_alta
	FROM clientes
	WHERE dni = p_dni;
END //
DELIMITER ;

CALL sp_buscar_cliente('12345678');
