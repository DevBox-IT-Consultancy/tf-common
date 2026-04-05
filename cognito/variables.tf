variable "app_name" {
  description = "Application name"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

# ========================
# User Pool Configuration
# ========================
variable "username_attributes" {
  description = "Username attributes (email, phone_number)"
  type        = list(string)
  default     = ["email"]
}

variable "auto_verified_attributes" {
  description = "Attributes to auto-verify"
  type        = list(string)
  default     = ["email"]
}

variable "password_policy" {
  description = "Password policy configuration"
  type = object({
    minimum_length                   = number
    require_lowercase                = bool
    require_uppercase                = bool
    require_numbers                  = bool
    require_symbols                  = bool
    temporary_password_validity_days = number
  })
  default = {
    minimum_length                   = 8
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = true
    temporary_password_validity_days = 7
  }
}

variable "user_attributes" {
  description = "User pool schema attributes"
  type = list(object({
    name                = string
    attribute_data_type = string
    required            = bool
    mutable             = bool
    min_length          = optional(number)
    max_length          = optional(number)
  }))
  default = [
    {
      name                = "email"
      attribute_data_type = "String"
      required            = true
      mutable             = true
      min_length          = 1
      max_length          = 256
    },
    {
      name                = "name"
      attribute_data_type = "String"
      required            = false
      mutable             = true
      min_length          = 1
      max_length          = 256
    }
  ]
}

variable "mfa_configuration" {
  description = "MFA configuration (OFF, ON, OPTIONAL)"
  type        = string
  default     = "OPTIONAL"
}

variable "advanced_security_mode" {
  description = "Advanced security mode (OFF, AUDIT, ENFORCED)"
  type        = string
  default     = "ENFORCED"
}

variable "deletion_protection" {
  description = "Deletion protection (ACTIVE, INACTIVE)"
  type        = string
  default     = "ACTIVE"
}

variable "cognito_domain" {
  description = "Cognito domain (leave empty for auto-generated)"
  type        = string
  default     = ""
}

# ========================
# Web Client Configuration
# ========================
variable "web_client_oauth_flows" {
  description = "OAuth flows for web client"
  type        = list(string)
  default     = ["code", "implicit"]
}

variable "web_client_oauth_scopes" {
  description = "OAuth scopes for web client"
  type        = list(string)
  default     = ["email", "openid", "profile", "aws.cognito.signin.user.admin"]
}

variable "web_client_callback_urls" {
  description = "Callback URLs for web client"
  type        = list(string)
}

variable "web_client_logout_urls" {
  description = "Logout URLs for web client"
  type        = list(string)
}

variable "web_client_identity_providers" {
  description = "Supported identity providers for web client"
  type        = list(string)
  default     = ["COGNITO"]
}

variable "web_client_token_validity" {
  description = "Token validity configuration for web client"
  type = object({
    id_token           = number
    access_token       = number
    refresh_token      = number
    id_token_unit      = string
    access_token_unit  = string
    refresh_token_unit = string
  })
  default = {
    id_token           = 60
    access_token       = 60
    refresh_token      = 30
    id_token_unit      = "minutes"
    access_token_unit  = "minutes"
    refresh_token_unit = "days"
  }
}

variable "web_client_read_attributes" {
  description = "Read attributes for web client"
  type        = list(string)
  default     = ["email", "email_verified", "name"]
}

variable "web_client_write_attributes" {
  description = "Write attributes for web client"
  type        = list(string)
  default     = ["email", "name"]
}

variable "web_client_auth_flows" {
  description = "Explicit auth flows for web client"
  type        = list(string)
  default     = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_PASSWORD_AUTH"]
}

# ========================
# API Client Configuration
# ========================
variable "api_client_token_validity" {
  description = "Token validity configuration for API client"
  type = object({
    id_token           = number
    access_token       = number
    refresh_token      = number
    id_token_unit      = string
    access_token_unit  = string
    refresh_token_unit = string
  })
  default = {
    id_token           = 60
    access_token       = 60
    refresh_token      = 30
    id_token_unit      = "minutes"
    access_token_unit  = "minutes"
    refresh_token_unit = "days"
  }
}

variable "api_client_read_attributes" {
  description = "Read attributes for API client"
  type        = list(string)
  default     = ["email", "email_verified", "name"]
}

variable "api_client_auth_flows" {
  description = "Explicit auth flows for API client"
  type        = list(string)
  default     = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_PASSWORD_AUTH"]
}

# ========================
# Identity Pool Configuration
# ========================
variable "allow_unauthenticated_identities" {
  description = "Allow unauthenticated identities"
  type        = bool
  default     = false
}

# ========================
# User Groups
# ========================
variable "user_groups" {
  description = "User groups to create"
  type = map(object({
    description = string
    precedence  = number
  }))
  default = {
    admin = {
      description = "Administrator group with full access"
      precedence  = 1
    }
    manager = {
      description = "Manager group with approval permissions"
      precedence  = 2
    }
    employee = {
      description = "Employee group with basic access"
      precedence  = 3
    }
  }
}

# ========================
# Tags
# ========================
variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
