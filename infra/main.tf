provider "aws" {
  region = "us-west-2"  # Ajusta la región según tus necesidades
}

# Crear un bucket de S3 para el destino con el nombre personalizado
resource "aws_s3_bucket" "bucket" {
  bucket = "albertapaza-iot-bucket"
}

# ARN del rol existente con los permisos necesarios
locals {
  existing_role_arn = "arn:aws:iam::183789758787:role/LabRole"  # Sustituye con tu ARN de LabRole
}

# Crear la función Lambda que procesará los datos de Firehose, usando el rol existente
resource "aws_lambda_function" "lambda_processor" {
  filename      = "lambda.zip"                    # Asegúrate de que el archivo lambda.zip esté disponible
  function_name = "albertapaza-firehose-processor"
  role          = local.existing_role_arn         # Usar rol existente
  handler       = "exports.handler"               # El nombre del handler en tu código Lambda
  runtime       = "nodejs20.x"                    # Versión del runtime para Lambda
}

# Crear el flujo de entrega de Kinesis Firehose con configuración extendida a S3, usando el rol existente
resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream" {
  name        = "albertapaza-kinesis-firehose-s3-stream"
  destination = "extended_s3"

  # Configuración de Extended S3
  extended_s3_configuration {
    role_arn   = local.existing_role_arn          # Usar rol existente
    bucket_arn = aws_s3_bucket.bucket.arn

    # Configuración del procesamiento de datos a través de Lambda
    processing_configuration {
      enabled = true

      processors {
        type = "Lambda"

        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${aws_lambda_function.lambda_processor.arn}:$LATEST"
        }
      }
    }
  }
}
