terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Las credenciales se toman del perfil activo de AWS CLI (variable AWS_PROFILE), nunca del código
provider "aws" {
  region = var.region
}

locals {
  prefijo_entregas   = "entregas/"
  prefijo_resultados = "resultados-athena/"
}

# Bucket privado con los datos y los resultados de Athena
resource "aws_s3_bucket" "datos" {
  bucket        = var.nombre_bucket
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "datos" {
  bucket                  = aws_s3_bucket.datos.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Base de datos del catálogo
resource "aws_glue_catalog_database" "entregas" {
  name = var.nombre_base_datos
}

# Tabla externa sobre los CSV, con partition projection por fecha
resource "aws_glue_catalog_table" "entregas" {
  name          = var.nombre_tabla
  database_name = aws_glue_catalog_database.entregas.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    "EXTERNAL"                       = "TRUE"
    "classification"                 = "csv"
    "skip.header.line.count"         = "1"
    "projection.enabled"             = "true"
    "projection.fecha.type"          = "date"
    "projection.fecha.format"        = "yyyy-MM-dd"
    "projection.fecha.range"         = var.rango_fechas
    "projection.fecha.interval"      = "1"
    "projection.fecha.interval.unit" = "DAYS"
    "storage.location.template"      = "s3://${aws_s3_bucket.datos.bucket}/${local.prefijo_entregas}fecha=$${fecha}/"
  }

  partition_keys {
    name = "fecha"
    type = "string"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.datos.bucket}/${local.prefijo_entregas}"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      name                  = "csv"
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
      parameters = {
        "field.delim"          = ","
        "serialization.format" = ","
      }
    }

    columns {
      name = "id_envio"
      type = "string"
    }
    columns {
      name = "ciudad"
      type = "string"
    }
    columns {
      name = "transportadora"
      type = "string"
    }
    columns {
      name = "estado"
      type = "string"
    }
    columns {
      name = "duracion_minutos"
      type = "int"
    }
  }
}

# Workgroup de Athena que escribe los resultados en resultados-athena/
resource "aws_athena_workgroup" "entregas" {
  name          = var.nombre_workgroup
  force_destroy = true

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = false

    result_configuration {
      output_location = "s3://${aws_s3_bucket.datos.bucket}/${local.prefijo_resultados}"
    }
  }
}
