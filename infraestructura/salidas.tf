output "bucket" {
  description = "Bucket S3 del ejercicio"
  value       = aws_s3_bucket.datos.bucket
}

output "ruta_entregas" {
  description = "Prefijo donde se cargan los CSV"
  value       = "s3://${aws_s3_bucket.datos.bucket}/${local.prefijo_entregas}"
}

output "ruta_resultados_athena" {
  description = "Prefijo donde Athena escribe los resultados"
  value       = "s3://${aws_s3_bucket.datos.bucket}/${local.prefijo_resultados}"
}

output "base_datos" {
  description = "Base de datos de Glue Data Catalog"
  value       = aws_glue_catalog_database.entregas.name
}

output "tabla" {
  description = "Tabla externa con partition projection"
  value       = aws_glue_catalog_table.entregas.name
}

output "workgroup" {
  description = "Workgroup de Athena"
  value       = aws_athena_workgroup.entregas.name
}

output "region" {
  description = "Región del despliegue"
  value       = var.region
}
