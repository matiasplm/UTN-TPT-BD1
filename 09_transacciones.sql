USE tp_integrador_bd1;

-- Tabla para pruebas de transacciones
DROP TABLE IF EXISTS cuentas;
CREATE TABLE cuentas (
    id_cuenta INT PRIMARY KEY,
    saldo DECIMAL(12,2) NOT NULL
) ENGINE=InnoDB;

INSERT INTO cuentas (id_cuenta, saldo) VALUES (1, 1000.00), (2, 1000.00);

-- Verificar nivel de aislamiento
SELECT @@transaction_isolation;