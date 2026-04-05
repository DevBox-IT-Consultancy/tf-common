# Terraform Common Modules

Reusable Terraform modules for AWS infrastructure components.

## Modules

### 1. Lambda (`lambda/`)
Creates an AWS Lambda function with IAM role.

**Features:**
- Lambda function with configurable runtime
- IAM role with necessary permissions
- VPC support (optional)
- Additional IAM policies (optional)

**Usage:**
```hcl
module "lambda" {
  source = "git::git@github.com:your-org/tf-common.git//lambda?ref=v1.0.0"
  
  app_name    = "my-app"
  environment = "dev"
  
  lambda_filename = "${path.module}/../target/function.zip"
  lambda_runtime  = "provided.al2023"
  
  lambda_environment_variables = {
    DB_HOST = "database.example.com"
  }
}
```

---

### 2. API Gateway (`apigateway/`)
Creates an HTTP API Gateway with Lambda integration.

**Features:**
- HTTP API Gateway
- Lambda integration (AWS_PROXY)
- CORS configuration
- CloudWatch access logs (optional)
- Lambda invocation permission

**Usage:**
```hcl
module "api_gateway" {
  source = "git::git@github.com:your-org/tf-common.git//apigateway?ref=v1.0.0"
  
  app_name    = "my-app"
  environment = "dev"
  
  lambda_function_name = module.lambda.function_name
  lambda_invoke_arn    = module.lambda.function_invoke_arn
  
  cors_allow_origins = ["*"]
}
```

---

### 3. CloudWatch (`cloudwatch/`)
Creates CloudWatch Log Groups.

**Features:**
- Multiple log groups creation
- Configurable retention period
- Tagging support

**Usage:**
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

---

## Complete Example

Here's how to use all three modules together:

```hcl
# Lambda Function
module "lambda" {
  source = "git::git@github.com:your-org/tf-common.git//lambda?ref=v1.0.0"
  
  app_name    = "my-app"
  environment = "dev"
  
  lambda_filename = "${path.module}/../target/function.zip"
  lambda_runtime  = "provided.al2023"
  
  lambda_environment_variables = {
    DB_HOST = "database.example.com"
  }
}

# CloudWatch Log Groups
module "cloudwatch" {
  source = "git::git@github.com:your-org/tf-common.git//cloudwatch?ref=v1.0.0"
  
  environment = "dev"
  
  log_groups = {
    lambda      = "/aws/lambda/${module.lambda.function_name}"
    api_gateway = "/aws/apigateway/my-app-dev"
  }
  
  retention_in_days = 7
}

# API Gateway
module "api_gateway" {
  source = "git::git@github.com:your-org/tf-common.git//apigateway?ref=v1.0.0"
  
  app_name    = "my-app"
  environment = "dev"
  
  lambda_function_name     = module.lambda.function_name
  lambda_invoke_arn        = module.lambda.function_invoke_arn
  cloudwatch_log_group_arn = module.cloudwatch.log_group_arns["api_gateway"]
  
  cors_allow_origins = ["*"]
  
  depends_on = [module.cloudwatch]
}
```

---

## Using Modules from GitHub

### Public Repository
```hcl
module "lambda" {
  source = "git::https://github.com:your-org/tf-common.git//lambda?ref=v1.0.0"
}
```

### Private Repository (SSH)
```hcl
module "lambda" {
  source = "git::git@github.com:your-org/tf-common.git//lambda?ref=v1.0.0"
}
```

### Private Repository (HTTPS with Token)
```bash
# Set GitHub token
export GITHUB_TOKEN=ghp_xxxxxxxxxxxxx

# Or use git credential helper
git config --global credential.helper store
```

```hcl
module "lambda" {
  source = "git::https://github.com/your-org/tf-common.git//lambda?ref=v1.0.0"
}
```

### Local Development
```hcl
module "lambda" {
  source = "../../tf-common/lambda"
}
```

---

## Versioning

Use Git tags for versioning:

```bash
git tag -a v1.0.0 -m "Initial release"
git push origin v1.0.0
```

Reference specific versions in your modules:
```hcl
source = "git::git@github.com:your-org/tf-common.git//lambda?ref=v1.0.0"
```

---

## Module Structure

Each module follows this structure:

```
module-name/
├── main.tf       # Main resources
├── variables.tf  # Input variables
├── outputs.tf    # Output values
└── README.md     # Module documentation
```

---

## Setup Instructions

### 1. Push to GitHub

```bash
cd tf-common
git init
git add .
git commit -m "Initial commit: Terraform modules"
git remote add origin git@github.com:your-org/tf-common.git
git push -u origin main

# Tag a version
git tag -a v1.0.0 -m "Initial release"
git push origin v1.0.0
```

### 2. Use in Your Projects

Update your Terraform configuration to use the modules:

```hcl
module "lambda" {
  source = "git::git@github.com:your-org/tf-common.git//lambda?ref=v1.0.0"
  # ... configuration
}
```

### 3. Initialize and Apply

```bash
terraform init
terraform plan
terraform apply
```

---

## Benefits

1. **Modularity**: Each service is a separate module
2. **Reusability**: Use across multiple projects
3. **Consistency**: Same infrastructure patterns everywhere
4. **Maintainability**: Update once, apply everywhere
5. **Version Control**: Pin to specific versions for stability
6. **Flexibility**: Compose modules as needed

---

## Contributing

1. Create a feature branch
2. Make changes to modules
3. Test locally
4. Create a pull request
5. Tag a new version after merge

---

## Best Practices

1. Always use version tags in production
2. Test modules locally before pushing
3. Document all variables and outputs
4. Use semantic versioning
5. Keep modules focused and single-purpose
6. Avoid hardcoding values
7. Use variables for configuration
8. Add examples in README files
