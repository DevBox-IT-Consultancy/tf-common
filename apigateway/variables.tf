variable "app_name" {
  description = "Application name"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

# ========================
# Lambda Integration
# ========================
variable "lambda_function_name" {
  description = "Name of the Lambda function to integrate"
  type        = string
}

variable "lambda_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  type        = string
}

# ========================
# API Gateway Configuration
# ========================
variable "api_stage_name" {
  description = "API Gateway stage name"
  type        = string
  default     = "$default"
}

variable "api_timeout_milliseconds" {
  description = "API Gateway integration timeout in milliseconds"
  type        = number
  default     = 30000
}

# ========================
# CORS Configuration
# ========================
variable "cors_allow_origins" {
  description = "CORS allowed origins"
  type        = list(string)
  default     = ["*"]
}

variable "cors_allow_methods" {
  description = "CORS allowed methods"
  type        = list(string)
  default     = ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS", "HEAD"]
}

variable "cors_allow_headers" {
  description = "CORS allowed headers"
  type        = list(string)
  default     = ["*"]
}

variable "cors_max_age" {
  description = "CORS max age in seconds"
  type        = number
  default     = 300
}

# ========================
# CloudWatch Configuration
# ========================
variable "cloudwatch_log_group_arn" {
  description = "CloudWatch Log Group ARN for API Gateway access logs (optional)"
  type        = string
  default     = null
}

# ========================
# Tags
# ========================
variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
