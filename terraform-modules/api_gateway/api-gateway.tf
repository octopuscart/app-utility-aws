resource "aws_api_gateway_rest_api" "api" {
  name        = "App-Utility-Api"
  description = "API for fetching YouTube metadata and sending Firebase notifications"
}


# YouTube Metadata Resource
resource "aws_api_gateway_resource" "youtube_metadata_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "youtubeMetadata"
}

resource "aws_api_gateway_method" "youtube_metadata_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.youtube_metadata_resource.id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "youtube_metadata_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.youtube_metadata_resource.id
  http_method             = aws_api_gateway_method.youtube_metadata_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/${var.youtube_metadata_arn}/invocations"

}

resource "aws_lambda_permission" "youtube_metadata_permission" {
  statement_id  = "AllowAPIGatewayInvokeYouTubeMetadata"
  action        = "lambda:InvokeFunction"
  function_name = var.youtube_metadata_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

# Firebase Notification Resource
resource "aws_api_gateway_resource" "firebase_notification_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "firebaseNotification"
}

resource "aws_api_gateway_method" "firebase_notification_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.firebase_notification_resource.id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "firebase_notification_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.firebase_notification_resource.id
  http_method             = aws_api_gateway_method.firebase_notification_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/${var.firebase_notification_arn}/invocations"
}


resource "aws_lambda_permission" "firebase_notification_permission" {
  statement_id  = "AllowAPIGatewayInvokeFirebaseNotification"
  action        = "lambda:InvokeFunction"
  function_name = var.firebase_notification_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.youtube_metadata_integration,
    aws_api_gateway_integration.firebase_notification_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "prod"
}

data "aws_ssm_parameter" "x_api_key" {
  name = "/app-utility/api-key"
  with_decryption = true
}

resource "aws_api_gateway_api_key" "api_key" {
  name    = "AppUtilityAPIKey"
  enabled = true
  value   = data.aws_ssm_parameter.x_api_key.value
}