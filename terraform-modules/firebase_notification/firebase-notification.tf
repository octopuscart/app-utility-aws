provider "aws" {
  region = "us-east-1" # Change to your desired region
}
data "aws_caller_identity" "current" {}
variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1" # Change this to your desired region if needed
}

variable "lambda_zip_path" {
  description = "The path to the Lambda function zip file"
  type        = string
  default     = "D:/projects/awsprojects/app-utility-deploy/temp/function.zip"
}



resource "aws_iam_role" "lambda_role" {
  name = "lambda-role-firebase-notification"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_ssm_policy" {
  name   = "lambda_ssm_policy"
  role = aws_iam_role.lambda_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ssm:GetParameter"
        ],
        Effect   = "Allow",
        Action   = "ssm:GetParameter"
        Resource = "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/app-utility/aws-admin-credentials"
      }
    ]
  })
}

resource "aws_lambda_function" "app-utility-firebase-notification" {
  filename         = var.lambda_zip_path
  function_name    = "SendPushNotificationFunction"
  role             = aws_iam_role.lambda_role.arn
  handler          = "handler.sendPushNotification"
  runtime          = "nodejs20.x"
  source_code_hash = filebase64sha256(var.lambda_zip_path)

  environment {
    variables = {
      NODE_ENV = "production"
    }
  }
}

output "lambda_function_name" {
  value = aws_lambda_function.app-utility-firebase-notification.function_name
}

output "lambda_function_arn" {
  value = aws_lambda_function.app-utility-firebase-notification.arn
}
