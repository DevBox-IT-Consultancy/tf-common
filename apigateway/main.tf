# ========================
# API Gateway Module
# Creates HTTP API Gateway with Lambda integration
# ========================

# ========================
# API Gateway (HTTP API)
# ========================
resource "aws_apigatewayv2_api" "main" {
  name          = "${var.app_name}-${var.environment}-api"
  protocol_type = "HTTP"
  description   = "${var.app_name} API Gateway for ${var.environment}"

  cors_configuration {
    allow_origins = var.cors_allow_origins
    allow_methods = var.cors_allow_methods
    allow_headers = var.cors_allow_headers
    max_age       = var.cors_max_age
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.app_name}-api-gateway"
      Environment = var.environment
    }
  )
}

# ========================
# Lambda Integration
# ========================
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.lambda_invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
  timeout_milliseconds   = var.api_timeout_milliseconds
}

# ========================
# Routes
# ========================
resource "aws_apigatewayv2_route" "catch_all_route" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "root_route" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "ANY /"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# ========================
# Stage & Deployment
# ========================
resource "aws_apigatewayv2_stage" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = var.api_stage_name
  auto_deploy = true

  dynamic "access_log_settings" {
    for_each = var.cloudwatch_log_group_arn != null ? [1] : []
    content {
      destination_arn = var.cloudwatch_log_group_arn
      format = jsonencode({
        requestId      = "$context.requestId"
        ip             = "$context.identity.sourceIp"
        requestTime    = "$context.requestTime"
        httpMethod     = "$context.httpMethod"
        routeKey       = "$context.routeKey"
        status         = "$context.status"
        protocol       = "$context.protocol"
        responseLength = "$context.responseLength"
        errorMessage   = "$context.error.message"
      })
    }
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.app_name}-api-stage"
      Environment = var.environment
    }
  )
}

# ========================
# Lambda Permission for API Gateway
# ========================
resource "aws_lambda_permission" "apigw_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}
