# CloudWatch Module

Terraform module for creating AWS CloudWatch Log Groups.

## Features

- Multiple log groups creation
- Configurable retention period
- Tagging support

## Usage

### Basic Example

```hcl
module "cloudwatch" {
  source = "git::git@github.com:your-org/tf-common.git//cloudwatch?ref=v1.0.0"

  environment = "dev"

  log_groups = {
    lambda      = "/aws/lambda/my-app-dev-function"
    api_gateway = "/aws/apigateway/my-app-dev"
  }

  retention_in_days = 7
}
```

### With Custom Retention

```hcl
module "cloudwatch" {
  source = "git::git@github.com:your-org/tf-common.git//cloudwatch?ref=v1.0.0"

  environment = "prod"

  log_groups = {
    lambda      = "/aws/lambda/my-app-prod-function"
    api_gateway = "/aws/apigateway/my-app-prod"
    application = "/app/my-app-prod"
  }

  retention_in_days = 30

  tags = {
    Project = "MyApp"
    Team    = "Backend"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment | `string` | n/a | yes |
| log_groups | Map of log groups | `map(string)` | n/a | yes |
| retention_in_days | Retention period | `number` | `7` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| log_group_names | Map of log group names |
| log_group_arns | Map of log group ARNs |

## Notes

- Log groups are created before Lambda/API Gateway to avoid race conditions
- Retention period applies to all log groups
- Use log group ARNs for API Gateway access logs configuration
