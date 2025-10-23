-- Creación de la base de datos
DROP DATABASE IF EXISTS tp_integrador_bd1;
CREATE DATABASE tp_integrador_bd1 CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE tp_integrador_bd1;

-- Tabla clientes
DROP TABLE IF EXISTS clientes;
CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    dni CHAR(8) NOT NULL,
    nombre VARCHAR(60) NOT NULL,
    apellido VARCHAR(60) NOT NULL,
    fecha_alta DATE NOT NULL DEFAULT (CURRENT_DATE),
    CONSTRAINT uq_clientes_dni UNIQUE (dni),
    CONSTRAINT chk_clientes_dni_len CHECK (CHAR_LENGTH(dni) = 8 AND dni REGEXP '^[0-9]+$')
);

-- Tabla perfiles_clientes
DROP TABLE IF EXISTS perfiles_clientes;
CREATE TABLE perfiles_clientes (
    id_cliente INT PRIMARY KEY,
    email VARCHAR(120) NOT NULL,
    telefono VARCHAR(30),
    CONSTRAINT uq_perfiles_email UNIQUE (email),
    CONSTRAINT fk_perfiles_cliente FOREIGN KEY (id_cliente)
        REFERENCES clientes(id_cliente) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabla ventas
DROP TABLE IF EXISTS ventas;
CREATE TABLE ventas (
    id_venta BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    fecha DATE NOT NULL,
    total DECIMAL(12,2) NOT NULL,
    estado VARCHAR(10) NOT NULL,
    CONSTRAINT fk_ventas_cliente FOREIGN KEY (id_cliente)
        REFERENCES clientes(id_cliente),
    CONSTRAINT chk_ventas_total CHECK (total >= 0),
    CONSTRAINT chk_ventas_estado CHECK (estado IN ('PENDIENTE','PAGADA','CANCELADA'))
);