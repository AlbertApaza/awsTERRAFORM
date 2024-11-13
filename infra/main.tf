provider "aws" {
  region = "us-west-2"  # Ajusta la región según tus necesidades
}

# Crear un bucket de S3 para el destino con el nombre personalizado
resource "aws_s3_bucket" "bucket" {
  bucket = "albertapaza-iot-bucket"
}

# Definir la política que permite a Firehose asumir el rol
data "aws_iam_policy_document" "firehose_assume_role" {
  statement {
    effect = "Allow"
    
    # Permitir a Firehose asumir el rol
    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Crear un rol IAM para Kinesis Firehose con el nombre personalizado
resource "aws_iam_role" "firehose_role" {
  name               = "albertapaza-firehose-role"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume_role.json
}

# Definir la política que permite a Lambda asumir el rol
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    # Permitir a Lambda asumir el rol
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Crear el rol IAM para Lambda con el nombre personalizado
resource "aws_iam_role" "lambda_iam" {
  name               = "albertapaza-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

# Crear la función Lambda que procesará los datos de Firehose
resource "aws_lambda_function" "lambda_processor" {
  filename      = "lambda.zip"                  # Asegúrate de que el archivo lambda.zip esté disponible
  function_name = "albertapaza-firehose-processor"
  role          = aws_iam_role.lambda_iam.arn
  handler       = "exports.handler"             # El nombre del handler en tu código Lambda
  runtime       = "nodejs20.x"                  # Versión del runtime para Lambda
}

# Crear el flujo de entrega de Kinesis Firehose con configuración extendida a S3
resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream" {
  name        = "albertapaza-kinesis-firehose-s3-stream"
  destination = "extended_s3"

  # Configuración de Extended S3
  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
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
