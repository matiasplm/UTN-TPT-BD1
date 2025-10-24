USE tp_integrador_bd1;

DELIMITER //

CREATE PROCEDURE sp_transferir (
	IN p_origen INT,
	IN p_destino INT,
	IN p_monto DECIMAL(12,2)
)
BEGIN
	DECLARE v_intento INT DEFAULT 0;
	DECLARE v_max_reintentos INT DEFAULT 3;
	DECLARE v_done BOOLEAN DEFAULT FALSE;

	DECLARE CONTINUE HANDLER FOR 1213
	BEGIN
		SET v_intento = v_intento + 1;
		ROLLBACK;
		DO SLEEP(0.2 * v_intento);
	END;

	reintentar: REPEAT
		START TRANSACTION;

		IF (SELECT saldo FROM cuentas WHERE id_cuenta = p_origen) >= p_monto THEN
			UPDATE cuentas SET saldo = saldo - p_monto WHERE id_cuenta = p_origen;
			UPDATE cuentas SET saldo = saldo + p_monto WHERE id_cuenta = p_destino;
			COMMIT;
			SET v_done = TRUE;
		ELSE
			ROLLBACK;
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = 'Saldo insuficiente para realizar la transferencia';
		END IF;

	UNTIL v_done = TRUE OR v_intento >= v_max_reintentos
	END REPEAT;

	IF v_done = FALSE THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Error persistente: transacción abortada por múltiples deadlocks';
	END IF;
END //

DELIMITER ;

