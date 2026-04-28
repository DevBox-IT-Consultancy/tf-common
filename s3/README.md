# S3 Module

Reusable Terraform module for creating an AWS S3 bucket with opinionated security defaults.

## Features

- Public access fully blocked by default
- Optional versioning
- Server-side encryption (AES-256 or SSE-KMS)
- Flexible lifecycle rules (expiration, noncurrent version cleanup, multipart abort)
- Optional bucket policy attachment
- Optional CORS configuration
- `force_destroy` flag for safe dev/staging teardown

## Usage

### Basic private bucket (theme storage)

```hcl
module "theme_storage" {
  source = "git::https://github.com/DevBox-IT-Consultancy/tf-common.git//s3?ref=master"

  bucket_name   = "1desk-dev-theme-storage-123456789012"
  force_destroy = true

  versioning_enabled = true
  sse_algorithm      = "AES256"

  lifecycle_rules = [
    {
      id                                 = "expire-old-versions"
      enabled                            = true
      noncurrent_version_expiration_days = 90
      abort_incomplete_multipart_upload_days = 7
    }
  ]

  tags = {
    Project     = "1desk"
    Environment = "dev"
  }
}
```

### Bucket with custom policy

```hcl
data "aws_iam_policy_document" "policy" {
  statement {
    sid    = "AllowLambdaReadWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
    ]

    resources = [
      module.theme_storage.bucket_arn,
      "${module.theme_storage.bucket_arn}/*",
    ]
  }
}

module "theme_storage" {
  source = "git::https://github.com/DevBox-IT-Consultancy/tf-common.git//s3?ref=master"

  bucket_name        = "my-bucket-123456789012"
  versioning_enabled = true
  bucket_policy_json = data.aws_iam_policy_document.policy.json

  tags = { Environment = "prod" }
}
```

### Bucket with CORS (for browser uploads)

```hcl
module "uploads" {
  source = "git::https://github.com/DevBox-IT-Consultancy/tf-common.git//s3?ref=master"

  bucket_name = "my-uploads-bucket"

  cors_rules = [
    {
      allowed_methods = ["GET", "PUT", "POST"]
      allowed_origins = ["https://admin.example.com"]
      allowed_headers = ["*"]
      max_age_seconds = 3000
    }
  ]

  tags = { Environment = "prod" }
}
```

### KMS-encrypted bucket

```hcl
module "secure_bucket" {
  source = "git::https://github.com/DevBox-IT-Consultancy/tf-common.git//s3?ref=master"

  bucket_name        = "my-secure-bucket"
  sse_algorithm      = "aws:kms"
  kms_key_id         = "arn:aws:kms:ap-southeast-1:123456789012:key/abc-123"
  bucket_key_enabled = true

  tags = { Environment = "prod" }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| bucket_name | Globally unique bucket name | string | — | yes |
| force_destroy | Destroy bucket even if non-empty | bool | false | no |
| block_public_acls | Block public ACLs | bool | true | no |
| block_public_policy | Block public bucket policies | bool | true | no |
| ignore_public_acls | Ignore public ACLs | bool | true | no |
| restrict_public_buckets | Restrict public bucket policies | bool | true | no |
| versioning_enabled | Enable object versioning | bool | false | no |
| sse_algorithm | Encryption algorithm (`AES256`, `aws:kms`, or `null`) | string | `AES256` | no |
| kms_key_id | KMS key ARN for SSE-KMS | string | null | no |
| bucket_key_enabled | Enable S3 Bucket Key (reduces KMS costs) | bool | true | no |
| lifecycle_rules | List of lifecycle rule objects | list(any) | [] | no |
| bucket_policy_json | JSON bucket policy document | string | null | no |
| cors_rules | List of CORS rule objects | list(any) | [] | no |
| tags | Tags to apply to all resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_id | Bucket name / ID |
| bucket_arn | Bucket ARN |
| bucket_name | Bucket name |
| bucket_domain_name | Global bucket domain name |
| bucket_regional_domain_name | Regional bucket domain name |
| bucket_region | AWS region the bucket is in |
| hosted_zone_id | Route 53 hosted zone ID for the region |

## Notes

- All public access is blocked by default — override only if you need a public static site.
- `force_destroy = true` is recommended for dev/staging so `terraform destroy` works cleanly.
- When using `sse_algorithm = "aws:kms"`, set `bucket_key_enabled = true` to reduce KMS API call costs.
- `bucket_policy_json` is applied after the public access block to avoid race conditions.
