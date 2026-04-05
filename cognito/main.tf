# ========================
# Cognito Module
# Creates Cognito User Pool and Identity Pool for authentication
# ========================

# ========================
# Cognito User Pool
# ========================
resource "aws_cognito_user_pool" "main" {
  name = "${var.app_name}-${var.environment}-user-pool"

  # Username configuration
  username_attributes      = var.username_attributes
  auto_verified_attributes = var.auto_verified_attributes

  # Password policy
  password_policy {
    minimum_length                   = var.password_policy.minimum_length
    require_lowercase                = var.password_policy.require_lowercase
    require_uppercase                = var.password_policy.require_uppercase
    require_numbers                  = var.password_policy.require_numbers
    require_symbols                  = var.password_policy.require_symbols
    temporary_password_validity_days = var.password_policy.temporary_password_validity_days
  }

  # Account recovery
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  # User attributes
  dynamic "schema" {
    for_each = var.user_attributes
    content {
      name                = schema.value.name
      attribute_data_type = schema.value.attribute_data_type
      required            = schema.value.required
      mutable             = schema.value.mutable

      dynamic "string_attribute_constraints" {
        for_each = schema.value.attribute_data_type == "String" ? [1] : []
        content {
          min_length = lookup(schema.value, "min_length", 1)
          max_length = lookup(schema.value, "max_length", 256)
        }
      }
    }
  }

  # MFA configuration
  mfa_configuration = var.mfa_configuration

  dynamic "software_token_mfa_configuration" {
    for_each = var.mfa_configuration != "OFF" ? [1] : []
    content {
      enabled = true
    }
  }

  # Email configuration
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  # User pool add-ons
  user_pool_add_ons {
    advanced_security_mode = var.advanced_security_mode
  }

  # Deletion protection
  deletion_protection = var.deletion_protection

  tags = merge(
    var.tags,
    {
      Name        = "${var.app_name}-user-pool"
      Environment = var.environment
    }
  )
}

# ========================
# Cognito User Pool Domain
# ========================
resource "aws_cognito_user_pool_domain" "main" {
  domain       = var.cognito_domain != "" ? var.cognito_domain : "${var.app_name}-${var.environment}-${data.aws_caller_identity.current.account_id}"
  user_pool_id = aws_cognito_user_pool.main.id
}

# ========================
# Cognito User Pool Client (Web App)
# ========================
resource "aws_cognito_user_pool_client" "web_client" {
  name         = "${var.app_name}-web-client"
  user_pool_id = aws_cognito_user_pool.main.id

  # OAuth configuration
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = var.web_client_oauth_flows
  allowed_oauth_scopes                 = var.web_client_oauth_scopes

  # Callback URLs
  callback_urls = var.web_client_callback_urls
  logout_urls   = var.web_client_logout_urls

  # Supported identity providers
  supported_identity_providers = var.web_client_identity_providers

  # Token validity
  id_token_validity      = var.web_client_token_validity.id_token
  access_token_validity  = var.web_client_token_validity.access_token
  refresh_token_validity = var.web_client_token_validity.refresh_token

  token_validity_units {
    id_token      = var.web_client_token_validity.id_token_unit
    access_token  = var.web_client_token_validity.access_token_unit
    refresh_token = var.web_client_token_validity.refresh_token_unit
  }

  # Prevent user existence errors
  prevent_user_existence_errors = "ENABLED"

  # Read and write attributes
  read_attributes  = var.web_client_read_attributes
  write_attributes = var.web_client_write_attributes

  # Enable token revocation
  enable_token_revocation = true

  # Explicit auth flows
  explicit_auth_flows = var.web_client_auth_flows
}

# ========================
# Cognito User Pool Client (API/Backend)
# ========================
resource "aws_cognito_user_pool_client" "api_client" {
  name         = "${var.app_name}-api-client"
  user_pool_id = aws_cognito_user_pool.main.id

  # No OAuth flows for API client
  allowed_oauth_flows_user_pool_client = false

  # Token validity
  id_token_validity      = var.api_client_token_validity.id_token
  access_token_validity  = var.api_client_token_validity.access_token
  refresh_token_validity = var.api_client_token_validity.refresh_token

  token_validity_units {
    id_token      = var.api_client_token_validity.id_token_unit
    access_token  = var.api_client_token_validity.access_token_unit
    refresh_token = var.api_client_token_validity.refresh_token_unit
  }

  # Prevent user existence errors
  prevent_user_existence_errors = "ENABLED"

  # Read attributes
  read_attributes = var.api_client_read_attributes

  # Enable token revocation
  enable_token_revocation = true

  # Explicit auth flows
  explicit_auth_flows = var.api_client_auth_flows
}

# ========================
# Cognito Identity Pool
# ========================
resource "aws_cognito_identity_pool" "main" {
  identity_pool_name               = "${var.app_name}_${var.environment}_identity_pool"
  allow_unauthenticated_identities = var.allow_unauthenticated_identities

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.web_client.id
    provider_name           = aws_cognito_user_pool.main.endpoint
    server_side_token_check = true
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.app_name}-identity-pool"
      Environment = var.environment
    }
  )
}

# ========================
# IAM Roles for Identity Pool
# ========================

# Authenticated role
resource "aws_iam_role" "authenticated" {
  name = "${var.app_name}-${var.environment}-cognito-authenticated"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.main.id
          }
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "authenticated"
          }
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.app_name}-cognito-authenticated-role"
      Environment = var.environment
    }
  )
}

# Authenticated role policy
resource "aws_iam_role_policy" "authenticated" {
  name = "${var.app_name}-${var.environment}-authenticated-policy"
  role = aws_iam_role.authenticated.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "mobileanalytics:PutEvents",
          "cognito-sync:*",
          "cognito-identity:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach roles to identity pool
resource "aws_cognito_identity_pool_roles_attachment" "main" {
  identity_pool_id = aws_cognito_identity_pool.main.id

  roles = {
    authenticated = aws_iam_role.authenticated.arn
  }
}

# ========================
# Cognito User Groups
# ========================
resource "aws_cognito_user_group" "groups" {
  for_each = var.user_groups

  name         = each.key
  user_pool_id = aws_cognito_user_pool.main.id
  description  = each.value.description
  precedence   = each.value.precedence
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}
