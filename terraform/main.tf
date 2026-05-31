provider "aws" {
  region = var.aws_region
}

# Lambda Function 
resource "aws_lambda_function" "feedback_lambda" {
  filename         = "../lambda/lambda.zip"
  function_name    = "feedback-handler"
  
  # AWS Academy Pre-created Student Role
  role             = "arn:aws:iam::555538962931:role/LabRole"
  
  handler          = "app.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = filebase64sha256("../lambda/lambda.zip")
}

# API Gateway v2 HTTP API
resource "aws_apigatewayv2_api" "feedback_api" {
  name          = "feedback-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "prod" {
  api_id      = aws_apigatewayv2_api.feedback_api.id
  name        = "prod"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.feedback_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.feedback_lambda.invoke_arn
}

resource "aws_apigatewayv2_route" "post_feedback" {
  api_id    = aws_apigatewayv2_api.feedback_api.id
  route_key = "POST /feedback"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.feedback_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.feedback_api.execution_arn}/*/*"
}

output "api_endpoint" {
  value = "${aws_apigatewayv2_api.feedback_api.api_endpoint}/prod/feedback"
}
