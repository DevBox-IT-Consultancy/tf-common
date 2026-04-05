# ========================
# Lambda Module
# Creates Lambda function with IAM role
# ========================

# ========================
# IAM Role for Lambda
# ========================
resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.app_name}-${var.environment}-lambda-role"

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

  tags = merge(
    var.tags,
    {
      Name        = "${var.app_name}-lambda-role"
      Environment = var.environment
    }
  )
}

# Basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# VPC execution policy (if VPC config is provided)
resource "aws_iam_role_policy_attachment" "lambda_vpc_execution" {
  count      = var.vpc_config != null ? 1 : 0
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Additional IAM policies (if provided)
resource "aws_iam_role_policy_attachment" "additional_policies" {
  for_each = toset(var.additional_policy_arns)
  
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = each.value
}

# ========================
# Lambda Function
# ========================
resource "aws_lambda_function" "main" {
  function_name = "${var.app_name}-${var.environment}-function"
  filename      = var.lambda_filename
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  memory_size   = var.lambda_memory_size
  timeout       = var.lambda_timeout
  architectures = var.lambda_architectures

  role = aws_iam_role.lambda_exec_role.arn

  source_code_hash = filebase64sha256(var.lambda_filename)

  environment {
    variables = merge(
      var.lambda_environment_variables,
      {
        ENVIRONMENT = var.environment
      }
    )
  }

  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [var.vpc_config] : []
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.app_name}-lambda"
      Environment = var.environment
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic
  ]
}
