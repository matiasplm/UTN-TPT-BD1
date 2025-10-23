USE tp_integrador_bd1;

-- Inserciones CORRECTAS (2 casos)
-- Caso A
INSERT INTO clientes (dni, nombre, apellido) VALUES ('12345678','Ana','Pérez');
INSERT INTO perfiles_clientes (id_cliente, email, telefono)
SELECT id_cliente, 'ana@example.com', '351-1111111' FROM clientes WHERE dni='12345678';
INSERT INTO ventas (id_cliente, fecha, total, estado)
SELECT id_cliente, '2025-09-01', 25000.00, 'PAGADA' FROM clientes WHERE dni='12345678';

-- Caso B
INSERT INTO clientes (dni, nombre, apellido) VALUES ('23456789','Luis','Gómez');
INSERT INTO perfiles_clientes (id_cliente, email)
SELECT id_cliente, 'luis@example.com' FROM clientes WHERE dni='23456789';
INSERT INTO ventas (id_cliente, fecha, total, estado)
SELECT id_cliente, '2025-09-02', 0.00, 'PENDIENTE' FROM clientes WHERE dni='23456789';

-- Inserciones ERRÓNEAS (2 tipos distintos)
-- Error tipo UNIQUE (dni duplicado)
INSERT INTO clientes (dni, nombre, apellido) VALUES ('12345678','Ana Duplicada','X');

-- Error tipo CHECK (total negativo)
INSERT INTO ventas (id_cliente, fecha, total, estado)
SELECT id_cliente, '2025-09-03', -10.00, 'PAGADA' FROM clientes WHERE dni='12345678';