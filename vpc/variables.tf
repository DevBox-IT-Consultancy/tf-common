variable "name" {
  description = "Name prefix for all VPC resources"
  type        = string
}

variable "aws_region" {
  description = "AWS region where the VPC is deployed (used for VPC endpoint service names)"
  type        = string
}

# ========================
# Network
# ========================
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones to use for subnets"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets used by Lambda and RDS (one per AZ)"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

# ========================
# Security Groups
# ========================
variable "rds_port" {
  description = "Port that the RDS instance listens on (used in the RDS security group ingress rule)"
  type        = number
  default     = 5432
}

# ========================
# VPC Endpoints
# Gateway endpoints are free and allow private subnet resources
# to reach S3 and DynamoDB without a NAT Gateway.
# ========================
variable "enable_s3_endpoint" {
  description = "Create a free Gateway VPC endpoint for S3"
  type        = bool
  default     = true
}

variable "enable_dynamodb_endpoint" {
  description = "Create a free Gateway VPC endpoint for DynamoDB"
  type        = bool
  default     = true
}

# ========================
# Tags
# ========================
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
