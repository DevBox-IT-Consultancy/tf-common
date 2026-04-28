# ========================
# Bucket Identity
# ========================
variable "bucket_name" {
  description = "Globally unique name for the S3 bucket."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9\\-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name must be 3–63 characters, lowercase letters, numbers, and hyphens only, and cannot start or end with a hyphen."
  }
}

variable "force_destroy" {
  description = "Allow Terraform to destroy the bucket even if it contains objects. Set true for dev/staging, false for prod."
  type        = bool
  default     = false
}

# ========================
# Public Access Block
# ========================
variable "block_public_acls" {
  description = "Block public ACLs on the bucket."
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Block public bucket policies."
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Ignore public ACLs on the bucket."
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Restrict public bucket policies."
  type        = bool
  default     = true
}

# ========================
# Versioning
# ========================
variable "versioning_enabled" {
  description = "Enable S3 object versioning."
  type        = bool
  default     = false
}

# ========================
# Encryption
# ========================
variable "sse_algorithm" {
  description = "Server-side encryption algorithm. Use 'AES256' for SSE-S3 or 'aws:kms' for SSE-KMS. Set null to skip encryption configuration."
  type        = string
  default     = "AES256"

  validation {
    condition     = var.sse_algorithm == null || contains(["AES256", "aws:kms"], var.sse_algorithm)
    error_message = "sse_algorithm must be 'AES256', 'aws:kms', or null."
  }
}

variable "kms_key_id" {
  description = "KMS key ARN or alias for SSE-KMS encryption. Required when sse_algorithm is 'aws:kms'."
  type        = string
  default     = null
}

variable "bucket_key_enabled" {
  description = "Enable S3 Bucket Key to reduce KMS request costs. Only applies when sse_algorithm is 'aws:kms'."
  type        = bool
  default     = true
}

# ========================
# Lifecycle Rules
# ========================
variable "lifecycle_rules" {
  description = <<-EOT
    List of lifecycle rules. Each rule supports:
      - id                                    (string, required)
      - enabled                               (bool, required)
      - prefix                                (string, optional) — filter by key prefix
      - expiration_days                       (number, optional) — expire current objects after N days
      - noncurrent_version_expiration_days    (number, optional) — expire non-current versions after N days
      - abort_incomplete_multipart_upload_days (number, optional) — abort incomplete uploads after N days
  EOT
  type        = list(any)
  default     = []
}

# ========================
# Bucket Policy
# ========================
variable "bucket_policy_json" {
  description = "JSON-encoded IAM bucket policy document. Use data.aws_iam_policy_document to generate this."
  type        = string
  default     = null
}

# ========================
# CORS
# ========================
variable "cors_rules" {
  description = <<-EOT
    List of CORS rules. Each rule supports:
      - allowed_methods (list of strings, required) — e.g. ["GET", "PUT"]
      - allowed_origins (list of strings, required) — e.g. ["https://example.com"]
      - allowed_headers (list of strings, optional) — defaults to ["*"]
      - expose_headers  (list of strings, optional) — defaults to []
      - max_age_seconds (number, optional)          — defaults to 3000
  EOT
  type        = list(any)
  default     = []
}

# ========================
# Tags
# ========================
variable "tags" {
  description = "Tags to apply to all resources created by this module."
  type        = map(string)
  default     = {}
}
