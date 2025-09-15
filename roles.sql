--admin: Acceso total a todas las tablas
CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'password_admin';
GRANT ALL PRIVILEGES ON sistema_soporte.* TO 'admin_user'@'localhost';
FLUSH PRIVILEGES;

--Rol soporte: Permisos de lectura y actualización
CREATE USER 'soporte_user'@'localhost' IDENTIFIED BY 'password_soporte';
GRANT SELECT, UPDATE ON sistema_soporte.solicitudes TO 'soporte_user'@'localhost';
GRANT SELECT, INSERT ON sistema_soporte.historial_cambios TO 'soporte_user'@'localhost';
GRANT SELECT ON sistema_soporte.clientes TO 'soporte_user'@'localhost';
GRANT SELECT ON sistema_soporte.usuarios_internos TO 'soporte_user'@'localhost';
FLUSH PRIVILEGES;

--Rol cliente: Solo puede ver sus propias solicitudes.


CREATE USER 'cliente_user'@'localhost' IDENTIFIED BY 'password_cliente';
-- Se le concede permiso para ver solo la tabla de solicitudes, pero la lógica de "ver sus propias solicitudes" se maneja a nivel de aplicación.
GRANT SELECT ON sistema_soporte.solicitudes TO 'cliente_user'@'localhost';



