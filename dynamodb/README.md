# DynamoDB Module

This module creates a DynamoDB table with configurable options.

## Features

- Flexible billing modes (PAY_PER_REQUEST or PROVISIONED)
- Support for hash key and optional range key
- Global Secondary Indexes (GSI)
- Local Secondary Indexes (LSI)
- TTL (Time To Live) support
- Point-in-time recovery
- Server-side encryption with optional KMS
- DynamoDB Streams support
- Customizable tags

## Usage

### Basic Table (Pay Per Request)

```hcl
module "dynamodb_table" {
  source = "git::https://github.com/DevBox-IT-Consultancy/tf-common.git//dynamodb?ref=main"

  table_name   = "my-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attributes = [
    {
      name = "id"
      type = "S"
    }
  ]

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```

### Table with Range Key

```hcl
module "dynamodb_table" {
  source = "git::https://github.com/DevBox-IT-Consultancy/tf-common.git//dynamodb?ref=main"

  table_name   = "my-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "userId"
  range_key    = "timestamp"

  attributes = [
    {
      name = "userId"
      type = "S"
    },
    {
      name = "timestamp"
      type = "N"
    }
  ]

  tags = {
    Environment = "dev"
  }
}
```

### Terraform State Lock Table

```hcl
module "state_lock" {
  source = "git::https://github.com/DevBox-IT-Consultancy/tf-common.git//dynamodb?ref=main"

  table_name   = "terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attributes = [
    {
      name = "LockID"
      type = "S"
    }
  ]

  tags = {
    Purpose = "Terraform State Locking"
  }
}
```

### Table with Global Secondary Index

```hcl
module "dynamodb_table" {
  source = "git::https://github.com/DevBox-IT-Consultancy/tf-common.git//dynamodb?ref=main"

  table_name   = "users"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "userId"

  attributes = [
    {
      name = "userId"
      type = "S"
    },
    {
      name = "email"
      type = "S"
    }
  ]

  global_secondary_indexes = [
    {
      name            = "EmailIndex"
      hash_key        = "email"
      projection_type = "ALL"
    }
  ]

  tags = {
    Environment = "prod"
  }
}
```

### Table with TTL and Point-in-Time Recovery

```hcl
module "dynamodb_table" {
  source = "git::https://github.com/DevBox-IT-Consultancy/tf-common.git//dynamodb?ref=main"

  table_name   = "sessions"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "sessionId"

  attributes = [
    {
      name = "sessionId"
      type = "S"
    }
  ]

  ttl_enabled            = true
  ttl_attribute_name     = "expiresAt"
  point_in_time_recovery = true

  tags = {
    Environment = "prod"
  }
}
```

### Table with Streams

```hcl
module "dynamodb_table" {
  source = "git::https://github.com/DevBox-IT-Consultancy/tf-common.git//dynamodb?ref=main"

  table_name   = "events"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "eventId"

  attributes = [
    {
      name = "eventId"
      type = "S"
    }
  ]

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  tags = {
    Environment = "prod"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| table_name | Name of the DynamoDB table | string | - | yes |
| billing_mode | Billing mode (PROVISIONED or PAY_PER_REQUEST) | string | PAY_PER_REQUEST | no |
| hash_key | Hash key (partition key) | string | - | yes |
| range_key | Range key (sort key) | string | null | no |
| attributes | List of attribute definitions | list(object) | - | yes |
| read_capacity | Read capacity units (PROVISIONED only) | number | 5 | no |
| write_capacity | Write capacity units (PROVISIONED only) | number | 5 | no |
| ttl_enabled | Enable TTL | bool | false | no |
| ttl_attribute_name | Attribute name for TTL | string | "ttl" | no |
| point_in_time_recovery | Enable point-in-time recovery | bool | false | no |
| encryption_enabled | Enable server-side encryption | bool | false | no |
| kms_key_arn | KMS key ARN for encryption | string | null | no |
| global_secondary_indexes | List of GSIs | list(object) | [] | no |
| local_secondary_indexes | List of LSIs | list(object) | [] | no |
| stream_enabled | Enable DynamoDB Streams | bool | false | no |
| stream_view_type | Stream view type | string | NEW_AND_OLD_IMAGES | no |
| tags | Tags to apply | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| table_id | ID of the DynamoDB table |
| table_name | Name of the DynamoDB table |
| table_arn | ARN of the DynamoDB table |
| stream_arn | ARN of the DynamoDB stream (if enabled) |
| stream_label | Label of the DynamoDB stream (if enabled) |

## Attribute Types

- `S` - String
- `N` - Number
- `B` - Binary

## Projection Types

- `ALL` - All attributes
- `KEYS_ONLY` - Only key attributes
- `INCLUDE` - Specified attributes (use with non_key_attributes)

## Stream View Types

- `KEYS_ONLY` - Only key attributes
- `NEW_IMAGE` - Entire item after modification
- `OLD_IMAGE` - Entire item before modification
- `NEW_AND_OLD_IMAGES` - Both new and old images
