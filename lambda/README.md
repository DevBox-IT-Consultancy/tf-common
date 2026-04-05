# Lambda Module

Terraform module for creating an AWS Lambda function with IAM role.

## Features

- Lambda function with configurable runtime and resources
- IAM role with necessary permissions
- Basic execution policy
- VPC access policy (optional)
- Additional custom policies (optional)
- Customizable environment variables

## Usage

### Basic Example

```hcl
module "lambda" {
  source = "git::git@github.com:your-org/tf-common.git//lambda?ref=v1.0.0"

  app_name    = "my-app"
  environment = "dev"

  lambda_filename = "${path.module}/../target/function.zip"
  lambda_handler  = "index.handler"
  lambda_runtime  = "nodejs18.x"

  lambda_environment_variables = {
    NODE_ENV = "production"
  }
}
```

### Quarkus Native Example

```hcl
module "lambda" {
  source = "git::git@github.com:your-org/tf-common.git//lambda?ref=v1.0.0"

  app_name    = "erp-api"
  environment = "dev"

  lambda_filename      = "${path.module}/../target/function.zip"
  lambda_handler       = "not.used.in.provided.runtime"
  lambda_runtime       = "provided.al2023"
  lambda_memory_size   = 1024
  lambda_timeout       = 30
  lambda_architectures = ["x86_64"]

  lambda_environment_variables = {
    DB_HOST     = "database.example.com"
    DB_PORT     = "5432"
    DB_NAME     = "mydb"
    DB_USER     = "dbuser"
    DB_PASSWORD = "dbpass"
  }
}
```

### With VPC Configuration

```hcl
module "lambda" {
  source = "git::git@github.com:your-org/tf-common.git//lambda?ref=v1.0.0"

  app_name    = "my-app"
  environment = "prod"

  lambda_filename = "${path.module}/../target/function.zip"
  lambda_runtime  = "provided.al2023"

  vpc_config = {
    subnet_ids         = ["subnet-xxx", "subnet-yyy"]
    security_group_ids = ["sg-xxx"]
  }

  lambda_environment_variables = {
    DB_HOST = "database.vpc.internal"
  }
}
```

### With Additional IAM Policies

```hcl
module "lambda" {
  source = "git::git@github.com:your-org/tf-common.git//lambda?ref=v1.0.0"

  app_name    = "my-app"
  environment = "dev"

  lambda_filename = "${path.module}/../target/function.zip"
  lambda_runtime  = "python3.11"

  additional_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess"
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app_name | Application name | `string` | n/a | yes |
| environment | Environment (dev, staging, prod) | `string` | n/a | yes |
| lambda_filename | Path to Lambda deployment package | `string` | n/a | yes |
| lambda_handler | Lambda function handler | `string` | `"index.handler"` | no |
| lambda_runtime | Lambda runtime | `string` | `"provided.al2023"` | no |
| lambda_memory_size | Lambda memory size in MB | `number` | `1024` | no |
| lambda_timeout | Lambda timeout in seconds | `number` | `30` | no |
| lambda_architectures | Lambda architectures | `list(string)` | `["x86_64"]` | no |
| lambda_environment_variables | Environment variables | `map(string)` | `{}` | no |
| vpc_config | VPC configuration | `object` | `null` | no |
| additional_policy_arns | Additional IAM policy ARNs | `list(string)` | `[]` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| function_name | Name of the Lambda function |
| function_arn | ARN of the Lambda function |
| function_invoke_arn | Invoke ARN of the Lambda function |
| function_qualified_arn | Qualified ARN of the Lambda function |
| role_arn | ARN of the Lambda execution role |
| role_name | Name of the Lambda execution role |

## Notes

- The module automatically includes basic Lambda execution policy
- VPC access policy is added only when `vpc_config` is provided
- Source code hash is automatically calculated from the zip file
- Environment variable `ENVIRONMENT` is automatically added
