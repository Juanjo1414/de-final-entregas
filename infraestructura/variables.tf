variable "region" {
  description = "Región de AWS donde se despliegan los recursos"
  type        = string
  default     = "us-east-1"
}

variable "nombre_bucket" {
  description = "Nombre global y único del bucket S3 del ejercicio"
  type        = string
  default     = "de-final-entregas-juanjo1414"
}

variable "nombre_base_datos" {
  description = "Base de datos de Glue Data Catalog"
  type        = string
  default     = "entregas_db"
}

variable "nombre_tabla" {
  description = "Tabla externa con los intentos de entrega"
  type        = string
  default     = "entregas"
}

variable "nombre_workgroup" {
  description = "Workgroup de Athena para las consultas del ejercicio"
  type        = string
  default     = "entregas_wg"
}

variable "rango_fechas" {
  description = "Rango de partition projection: fecha inicial y final, ambas incluidas"
  type        = string
  default     = "2026-10-01,2026-10-03"
}
