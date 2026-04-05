# Cognito Module

Terraform module for creating AWS Cognito User Pool and Identity Pool for authentication.

## Features

- User Pool with email-based authentication
- Configurable password policy
- MFA support (optional)
- Web client for frontend (OAuth 2.0)
- API client for backend
- Identity Pool for AWS credentials
- User groups (admin, manager, employee)
- Advanced security mode

## Usage

### Basic Example

```hcl
module "cognito" {
  source = "git::https://github.com/DevBox-IT-Consultancy/tf-common.git//cognito?ref=main"

  app_name    = "my-app"
  environment = "dev"

  web_client_callback_urls = [
    "http://localhost:3000/auth/callback"
  ]

  web_client_logout_urls = [
    "http://localhost:3000"
  ]
}
```

### Production Example

```hcl
module "cognito" {
  source = "git::https://github.com/DevBox-IT-Consultancy/tf-common.git//cognito?ref=v1.0.0"

  app_name    = "my-app"
  environment = "prod"

  # Callback URLs
  web_client_callback_urls = [
    "https://app.example.com/auth/callback"
  ]

  web_client_logout_urls = [
    "https://app.example.com"
  ]

  # Password policy
  password_policy = {
    minimum_length                   = 12
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = true
    temporary_password_validity_days = 3
  }

  # MFA required
  mfa_configuration = "ON"

  # Custom user groups
  user_groups = {
    admin = {
      description = "Administrators"
      precedence  = 1
    }
    user = {
      description = "Regular users"
      precedence  = 2
    }
  }

  tags = {
    Project = "MyApp"
    Team    = "Platform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app_name | Application name | `string` | n/a | yes |
| environment | Environment | `string` | n/a | yes |
| web_client_callback_urls | Callback URLs | `list(string)` | n/a | yes |
| web_client_logout_urls | Logout URLs | `list(string)` | n/a | yes |
| password_policy | Password policy | `object` | See variables.tf | no |
| mfa_configuration | MFA config | `string` | `"OPTIONAL"` | no |
| user_groups | User groups | `map(object)` | admin, manager, employee | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| user_pool_id | User Pool ID |
| user_pool_arn | User Pool ARN |
| web_client_id | Web Client ID (frontend) |
| api_client_id | API Client ID (backend) |
| identity_pool_id | Identity Pool ID |
| hosted_ui_url | Hosted UI URL |

## User Groups

Default groups created:
- **admin**: Full system access (precedence 1)
- **manager**: Approval permissions (precedence 2)
- **employee**: Basic access (precedence 3)

## Notes

- User Pool has deletion protection enabled
- Advanced security mode is enforced by default
- MFA is optional by default (can be set to ON or OFF)
- Tokens are revocable
- Email verification is automatic
