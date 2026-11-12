# Respuestas

## 1. ¿Por qué se pudo consultar el tercer día sin registrar una partición nueva?

Porque la tabla no depende de una lista de particiones guardada en Glue. Con partition projection, Athena calcula las particiones en el momento de la consulta a partir de las reglas que dejamos en las propiedades de la tabla: `projection.fecha.type = date`, formato `yyyy-MM-dd`, rango `2026-10-01,2026-10-03` e intervalo de 1 día. Con esas reglas, Athena genera las fechas 2026-10-01, 2026-10-02 y 2026-10-03 y, con `storage.location.template`, arma el prefijo de cada una: `s3://<bucket>/entregas/fecha=<fecha>/`.

El 2026-10-03 estaba proyectado desde el despliegue inicial. En la primera etapa su prefijo no tenía objetos, así que Athena no encontró filas para esa fecha: los resultados iniciales solo muestran el 1 y el 2 de octubre, con 12 registros. Cuando subimos `entregas/fecha=2026-10-03/entregas.csv`, la misma ruta que Athena ya calculaba pasó a tener un archivo. La siguiente consulta lo leyó directamente: `verificacion_tercer_dia.csv` muestra los seis registros (ENV-013 a ENV-018), el conteo por estado da 3 `destinatario_ausente`, 1 `direccion_incorrecta` y 2 `entregado`, y la tabla pasó a 18 registros. Los resultados finales de intentos y porcentaje coinciden con las referencias. No corrimos crawlers, `MSCK REPAIR TABLE` ni `ALTER TABLE ADD PARTITION`, ni cambiamos la tabla.

## 2. Si se subiera un archivo para el 4 de octubre manteniendo la configuración actual, ¿qué resultado se esperaría y qué se debería modificar para incluirlo?

El archivo quedaría guardado en S3, pero Athena no lo leería. El rango proyectado termina en 2026-10-03, así que Athena nunca genera la fecha 2026-10-04 ni construye su ruta. Las consultas seguirían devolviendo 18 registros y tres fechas, y un filtro `WHERE fecha = '2026-10-04'` devolvería cero filas sin error. La proyección no lista S3 buscando carpetas nuevas: solo considera las fechas que caen dentro de su rango.

Para incluirlo habría que ampliar `projection.fecha.range`, por ejemplo a `2026-10-01,2026-10-31`, o usar un extremo relativo como `2026-10-01,NOW`. Como toda la tabla está en Terraform, el cambio se hace en la variable `rango_fechas` y se aplica con `terraform apply`, no desde la consola. Después de ese cambio no hace falta registrar la partición: basta con que el archivo esté en `entregas/fecha=2026-10-04/entregas.csv`. Con un rango amplio, las fechas sin archivo simplemente no aportan filas.
