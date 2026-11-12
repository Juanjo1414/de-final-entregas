-- Cantidad de intentos por fecha y estado (todas las fechas proyectadas)
SELECT
    fecha,
    estado,
    COUNT(*) AS total_intentos
FROM entregas_db.entregas
GROUP BY fecha, estado
ORDER BY fecha ASC, estado ASC
