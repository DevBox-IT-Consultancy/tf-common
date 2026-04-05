# API Gateway Module

Terraform module for creating an AWS API Gateway (HTTP API) with Lambda integration.

## Features

- HTTP API Gateway
- Lambda integration (AWS_PROXY)
- CORS configuration
- Catch-all routing (ANY /{proxy+})
- CloudWatch access logs (optional)
- Lambda invocation permission

## Usage

### Basic Example

```hcl
module "api_gateway" {
  source = "git::git@github.com:your-org/tf-common.git//apigateway?ref=v1.0.0"

  app_name    = "my-app"
  environment = "dev"

  lambda_function_name = module.lambda.function_name
  lambda_invoke_arn    = module.lambda.function_invoke_arn
}
```

### With CORS Configuration

```hcl
module "api_gateway" {
  source = "git::git@github.com:your-org/tf-common.git//apigateway?ref=v1.0.0"

  app_name    = "my-app"
  environment = "prod"

  lambda_function_name = module.lambda.function_name
  lambda_invoke_arn    = module.lambda.function_invoke_arn

  cors_allow_origins = ["https://example.com", "https://app.example.com"]
  cors_allow_methods = ["GET", "POST", "PUT", "DELETE"]
  cors_allow_headers = ["Content-Type", "Authorization"]
}
```

### With CloudWatch Logs

```hcl
module "api_gateway" {
  source = "git::git@github.com:your-org/tf-common.git//apigateway?ref=v1.0.0"

  app_name    = "my-app"
  environment = "dev"

  lambda_function_name = module.lambda.function_name
  lambda_invoke_arn    = module.lambda.function_invoke_arn

  cloudwatch_log_group_arn = module.cloudwatch.log_group_arn
}
```

### Complete Example with All Modules

```hcl
# Lambda
module "lambda" {
  source = "git::git@github.com:your-org/tf-common.git//lambda?ref=v1.0.0"
  
  app_name    = "my-app"
  environment = "dev"
  
  lambda_filename = "${path.module}/../target/function.zip"
  lambda_runtime  = "provided.al2023"
}

# CloudWatch
module "cloudwatch" {
  source = "git::git@github.com:your-org/tf-common.git//cloudwatch?ref=v1.0.0"
  
  app_name    = "my-app"
  environment = "dev"
  
  log_groups = {
    lambda      = "/aws/lambda/${module.lambda.function_name}"
    api_gateway = "/aws/apigateway/my-app-dev"
  }
}

# API Gateway
module "api_gateway" {
  source = "git::git@github.com:your-org/tf-common.git//apigateway?ref=v1.0.0"
  
  app_name    = "my-app"
  environment = "dev"
  
  lambda_function_name     = module.lambda.function_name
  lambda_invoke_arn        = module.lambda.function_invoke_arn
  cloudwatch_log_group_arn = module.cloudwatch.log_group_arns["api_gateway"]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app_name | Application name | `string` | n/a | yes |
| environment | Environment (dev, staging, prod) | `string` | n/a | yes |
| lambda_function_name | Lambda function name | `string` | n/a | yes |
| lambda_invoke_arn | Lambda invoke ARN | `string` | n/a | yes |
| api_stage_name | API Gateway stage name | `string` | `"$default"` | no |
| api_timeout_milliseconds | Integration timeout | `number` | `30000` | no |
| cors_allow_origins | CORS allowed origins | `list(string)` | `["*"]` | no |
| cors_allow_methods | CORS allowed methods | `list(string)` | `[...]` | no |
| cors_allow_headers | CORS allowed headers | `list(string)` | `["*"]` | no |
| cors_max_age | CORS max age | `number` | `300` | no |
| cloudwatch_log_group_arn | CloudWatch log group ARN | `string` | `null` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| api_id | API Gateway ID |
| api_endpoint | API Gateway endpoint URL |
| api_execution_arn | API Gateway execution ARN |
| stage_name | API Gateway stage name |
| stage_arn | API Gateway stage ARN |

## Notes

- Uses HTTP API (not REST API) for lower cost and better performance
- Stage name defaults to `$default` to avoid stage prefix in URLs
- Automatically creates catch-all routes (ANY / and ANY /{proxy+})
- Lambda permission is automatically created for API Gateway invocation
- CloudWatch logs are optional (provide `cloudwatch_log_group_arn` to enable)
