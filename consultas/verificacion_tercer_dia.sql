-- Consulta 1: los seis registros del 2026-10-03
SELECT id_envio, ciudad, transportadora, estado, duracion_minutos, fecha
FROM entregas_db.entregas
WHERE fecha = '2026-10-03'
ORDER BY id_envio;

-- Consulta 2: conteos por estado del 2026-10-03
SELECT fecha, estado, COUNT(*) AS total_intentos
FROM entregas_db.entregas
WHERE fecha = '2026-10-03'
GROUP BY fecha, estado
ORDER BY estado;

-- Consulta 3: total de registros de la tabla y por fecha
SELECT COUNT(*) AS total_registros,
       COUNT(DISTINCT fecha) AS fechas_con_datos
FROM entregas_db.entregas;
