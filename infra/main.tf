provider "aws" {
  region = "us-east-1"  # Ajusta la región según lo que necesites
}

# Verificar si el bucket S3 ya existe
data "aws_s3_bucket" "existing_bucket" {
  bucket = "albertkenyiapazaaccallee"
}

# Si el bucket existe, eliminarlo (forzar eliminación de objetos)
resource "aws_s3_bucket_object" "empty_bucket" {
  count   = length(data.aws_s3_bucket.existing_bucket.bucket) > 0 ? 1 : 0
  bucket  = "albertkenyiapazaaccallee"
  key     = "empty-object"
  acl     = "private"
}

# Eliminar el bucket si existe (vacío)
resource "aws_s3_bucket" "bucket" {
  bucket = "albertkenyiapazaaccallee"

  lifecycle {
    prevent_destroy = false  # Permite la destrucción
  }

  force_destroy = true  # Elimina todos los objetos dentro del bucket
}

# Crear el nuevo bucket con el nombre si no existe
resource "aws_s3_bucket" "new_bucket" {
  count   = length(data.aws_s3_bucket.existing_bucket.bucket) > 0 ? 0 : 1
  bucket  = "albertkenyiapazaaccallee"
  acl     = "private"
}

# Configurar el ACL del bucket S3 a privado
resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.new_bucket[0].id
  acl    = "private"
}

# Definir la política que permite a Firehose asumir el rol (eliminación de roles IAM)
data "aws_iam_policy_document" "firehose_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Crear el flujo de entrega de Kinesis Firehose con configuración extendida a S3
resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream" {
  name        = "albertapaza-kinesis-firehose-s3-stream"
  destination = "extended_s3"

  # Configuración de Extended S3
  extended_s3_configuration {
    role_arn   = data.aws_iam_policy_document.firehose_assume_role.arn
    bucket_arn = aws_s3_bucket.new_bucket[0].arn

    # Configuración del procesamiento de datos a través de Lambda
    processing_configuration {
      enabled = "true"

      processors {
        type = "Lambda"

        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "arn:aws:lambda:us-east-1:000000000000:function:your_lambda_function"
        }
      }
    }
  }
}
