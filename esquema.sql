CREATE DATABASE IF NOT EXISTS sistema_soporte;
USE sistema_soporte;

-- Tabla de Clientes
CREATE TABLE IF NOT EXISTS clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(20)
);

-- Tabla de Usuarios Internos (Agentes y Administradores)
CREATE TABLE IF NOT EXISTS usuarios_internos (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    rol ENUM('admin', 'agente_soporte') NOT NULL,
    activo BOOLEAN DEFAULT TRUE
);

-- Tabla de Solicitudes
CREATE TABLE IF NOT EXISTS solicitudes (
    id_solicitud INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_agente INT,
    asunto VARCHAR(255) NOT NULL,
    descripcion TEXT NOT NULL,
    estado ENUM('abierta', 'en_proceso', 'cerrada') NOT NULL DEFAULT 'abierta',
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_ultima_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_cierre DATETIME,
    CONSTRAINT fk_solicitud_cliente FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
    CONSTRAINT fk_solicitud_agente FOREIGN KEY (id_agente) REFERENCES usuarios_internos(id_usuario)
);

-- Tabla de Historial de Cambios de Solicitudes
CREATE TABLE IF NOT EXISTS historial_cambios (
    id_historial INT AUTO_INCREMENT PRIMARY KEY,
    id_solicitud INT NOT NULL,
    id_usuario_cambio INT NOT NULL,
    cambio_descripcion VARCHAR(255) NOT NULL,
    fecha_cambio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_historial_solicitud FOREIGN KEY (id_solicitud) REFERENCES solicitudes(id_solicitud),
    CONSTRAINT fk_historial_usuario FOREIGN KEY (id_usuario_cambio) REFERENCES usuarios_internos(id_usuario)
);