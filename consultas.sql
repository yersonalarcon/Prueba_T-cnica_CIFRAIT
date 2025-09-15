--Listar todas las solicitudes abiertas por cliente
SELECT s.id_solicitud, s.asunto, c.nombre AS cliente_nombre
FROM solicitudes s
JOIN clientes c ON s.id_cliente = c.id_cliente
WHERE s.estado = 'abierta'
ORDER BY c.nombre;

--Promedio de tiempo de resolución de solicitudes
SELECT AVG(DATEDIFF(fecha_cierre, fecha_creacion)) AS promedio_dias_resolucion
FROM solicitudes
WHERE estado = 'cerrada' AND fecha_cierre IS NOT NULL;



--Cantidad de solicitudes cerradas por agente de soporte en el último mes
SELECT ui.nombre AS agente_nombre, COUNT(s.id_solicitud) AS solicitudes_cerradas
FROM solicitudes s
JOIN usuarios_internos ui ON s.id_agente = ui.id_usuario
WHERE s.estado = 'cerrada'
AND s.fecha_cierre >= CURDATE() - INTERVAL 1 MONTH
GROUP BY ui.nombre
ORDER BY solicitudes_cerradas DESC;


--Clientes con más solicitudes abiertas actualmente
SELECT c.nombre AS cliente_nombre, COUNT(s.id_solicitud) AS solicitudes_abiertas
FROM solicitudes s
JOIN clientes c ON s.id_cliente = c.id_cliente
WHERE s.estado = 'abierta'
GROUP BY c.nombre
ORDER BY solicitudes_abiertas DESC
LIMIT 10;

--Tiempo promedio de respuesta (creación a primera atención)
SELECT AVG(TIMESTAMPDIFF(MINUTE, s.fecha_creacion, MIN(hc.fecha_cambio))) AS minutos_hasta_primera_atencion
FROM solicitudes s
JOIN historial_cambios hc ON s.id_solicitud = hc.id_solicitud
WHERE hc.cambio_descripcion LIKE 'Estado cambiado a en_proceso%'
GROUP BY s.id_solicitud;


--Procedimiento Almacenado
DELIMITER $$
CREATE PROCEDURE cerrar_solicitudes_antiguas()
BEGIN
    UPDATE solicitudes
    SET estado = 'cerrada',
        fecha_cierre = CURRENT_TIMESTAMP
    WHERE estado = 'abierta'
    AND fecha_ultima_actualizacion < DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 30 DAY);
END$$
DELIMITER ;



