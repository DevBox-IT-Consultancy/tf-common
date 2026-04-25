# VPC Module

This module creates a VPC designed to host Lambda and RDS in private subnets at no extra cost.

## Cost Considerations

AWS charges for NAT Gateways (~$32/month + data transfer). This module deliberately omits one. Instead:

- **Private subnets** have no route to the internet — Lambda and RDS are fully isolated.
- **Free Gateway VPC endpoints** for S3 and DynamoDB are included so private resources can reach those services without a NAT Gateway.
- If your Lambda needs to call other AWS services (e.g., Secrets Manager, SSM), you can add Interface endpoints, but those are billed per hour. The free alternative is to pass configuration via environment variables instead.

## Features

- VPC with configurable CIDR
- Public subnets (for load balancers or bastion hosts)
- Private subnets for Lambda and RDS (no internet route)
- Internet Gateway for public subnets
- Separate route tables for public and private subnets
- Pre-configured security groups for Lambda and RDS with least-privilege rules
- Free Gateway VPC endpoints for S3 and DynamoDB

## Usage

### Basic (two AZs, free-tier friendly)

```hcl
module "vpc" {
  source = "git::https://github.com/DevBox-IT-Consultancy/tf-common.git//vpc?ref=main"

  name       = "myapp"
  aws_region = "us-east-1"

  availability_zones   = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```

### Wire up Lambda and RDS

Pass the VPC outputs directly to the Lambda and RDS modules:

```hcl
module "vpc" {
  source = "git::https://github.com/DevBox-IT-Consultancy/tf-common.git//vpc?ref=main"

  name       = "myapp"
  aws_region = "us-east-1"

  availability_zones   = ["us-east-1a", "us-east-1b"]
  private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]
  rds_port             = 5432  # match your engine (5432 = postgres, 3306 = mysql)

  tags = { Environment = "prod" }
}

module "lambda" {
  source = "git::https://github.com/DevBox-IT-Consultancy/tf-common.git//lambda?ref=main"

  # ... other lambda vars ...

  vpc_config = {
    subnet_ids         = module.vpc.private_subnet_ids
    security_group_ids = [module.vpc.lambda_security_group_id]
  }
}

module "rds" {
  source = "git::https://github.com/DevBox-IT-Consultancy/tf-common.git//rds?ref=main"

  # ... other rds vars ...

  subnet_ids             = module.vpc.private_subnet_ids
  vpc_security_group_ids = [module.vpc.rds_security_group_id]
  publicly_accessible    = false
}
```

### MySQL port

```hcl
module "vpc" {
  source = "git::https://github.com/DevBox-IT-Consultancy/tf-common.git//vpc?ref=main"

  name       = "myapp"
  aws_region = "eu-west-1"

  availability_zones   = ["eu-west-1a", "eu-west-1b"]
  private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]

  rds_port = 3306  # MySQL / MariaDB

  tags = { Environment = "staging" }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Name prefix for all resources | string | - | yes |
| aws_region | AWS region (used for endpoint service names) | string | - | yes |
| availability_zones | List of AZs for subnets | list(string) | - | yes |
| vpc_cidr | CIDR block for the VPC | string | 10.0.0.0/16 | no |
| public_subnet_cidrs | CIDR blocks for public subnets | list(string) | ["10.0.1.0/24", "10.0.2.0/24"] | no |
| private_subnet_cidrs | CIDR blocks for private subnets | list(string) | ["10.0.101.0/24", "10.0.102.0/24"] | no |
| rds_port | Port for the RDS security group ingress rule | number | 5432 | no |
| enable_s3_endpoint | Create a free S3 Gateway endpoint | bool | true | no |
| enable_dynamodb_endpoint | Create a free DynamoDB Gateway endpoint | bool | true | no |
| tags | Tags to apply to all resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | ID of the VPC |
| vpc_arn | ARN of the VPC |
| vpc_cidr | CIDR block of the VPC |
| public_subnet_ids | IDs of the public subnets |
| private_subnet_ids | IDs of the private subnets |
| public_subnet_cidrs | CIDR blocks of the public subnets |
| private_subnet_cidrs | CIDR blocks of the private subnets |
| public_route_table_id | ID of the public route table |
| private_route_table_id | ID of the private route table |
| lambda_security_group_id | Security group ID for Lambda |
| rds_security_group_id | Security group ID for RDS |
| internet_gateway_id | ID of the Internet Gateway |
| s3_endpoint_id | ID of the S3 Gateway endpoint |
| dynamodb_endpoint_id | ID of the DynamoDB Gateway endpoint |

## Security Group Rules

**Lambda SG**
- Egress: all traffic within the VPC CIDR (so it can reach RDS and VPC endpoints)

**RDS SG**
- Ingress: TCP on `rds_port` from the Lambda SG only
- Egress: all traffic within the VPC CIDR

## Notes

- RDS requires at least **two private subnets in different AZs** for the DB subnet group, even for single-AZ deployments.
- Set `publicly_accessible = false` on the RDS module (it defaults to false already).
- Gateway endpoints (S3, DynamoDB) are **free**. Interface endpoints for other services (Secrets Manager, SQS, etc.) are billed per hour — avoid them to stay free.
- If Lambda needs internet access (e.g., to call a third-party API), you will need a NAT Gateway or NAT Instance, which incurs cost. Consider restructuring to avoid that dependency.
