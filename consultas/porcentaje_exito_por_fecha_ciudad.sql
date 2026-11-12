-- Porcentaje de entregas exitosas por fecha y ciudad (denominador: todos los intentos)
SELECT
    fecha,
    ciudad,
    CAST(
        ROUND(100.0 * SUM(CASE WHEN estado = 'entregado' THEN 1 ELSE 0 END) / COUNT(*), 2)
        AS DECIMAL(5, 2)
    ) AS porcentaje_exito
FROM entregas_db.entregas
GROUP BY fecha, ciudad
ORDER BY fecha ASC, ciudad ASC
