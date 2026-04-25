# RDS Module

This module creates an RDS database instance with configurable options.

## Features

- Support for all major engines (MySQL, PostgreSQL, MariaDB, Oracle, SQL Server)
- Custom DB subnet group
- Optional custom parameter group with dynamic parameters
- Storage autoscaling support
- Storage encryption with optional KMS key
- Multi-AZ deployment
- Automated backups with configurable retention
- Enhanced monitoring and Performance Insights
- CloudWatch log exports
- Deletion protection
- Customizable tags

## Usage

### MySQL Instance (Basic)

```hcl
module "rds" {
  source = "git::https://github.com/DevBox-IT-Consultancy/tf-common.git//rds?ref=main"

  identifier     = "my-mysql-db"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"

  db_name  = "myapp"
  username = "admin"
  password = "supersecret"

  subnet_ids             = ["subnet-abc123", "subnet-def456"]
  vpc_security_group_ids = ["sg-abc123"]

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```

### PostgreSQL Instance with Multi-AZ

```hcl
module "rds" {
  source = "git::https://github.com/DevBox-IT-Consultancy/tf-common.git//rds?ref=main"

  identifier     = "my-postgres-db"
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.t3.medium"

  allocated_storage     = 50
  max_allocated_storage = 200
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = "myapp"
  username = "dbadmin"
  password = "supersecret"

  subnet_ids             = ["subnet-abc123", "subnet-def456"]
  vpc_security_group_ids = ["sg-abc123"]
  multi_az               = true

  backup_retention_period = 14
  backup_window           = "02:00-03:00"
  maintenance_window      = "Mon:03:00-Mon:04:00"

  deletion_protection = true

  tags = {
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
}
```

### Instance with Custom Parameter Group

```hcl
module "rds" {
  source = "git::https://github.com/DevBox-IT-Consultancy/tf-common.git//rds?ref=main"

  identifier     = "my-mysql-db"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.small"

  db_name  = "myapp"
  username = "admin"
  password = "supersecret"

  subnet_ids             = ["subnet-abc123", "subnet-def456"]
  vpc_security_group_ids = ["sg-abc123"]

  create_parameter_group = true
  parameter_group_family = "mysql8.0"
  parameters = [
    {
      name  = "max_connections"
      value = "200"
    },
    {
      name         = "slow_query_log"
      value        = "1"
      apply_method = "immediate"
    }
  ]

  tags = {
    Environment = "staging"
  }
}
```

### Instance with Enhanced Monitoring and Performance Insights

```hcl
module "rds" {
  source = "git::https://github.com/DevBox-IT-Consultancy/tf-common.git//rds?ref=main"

  identifier     = "my-postgres-db"
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.r6g.large"

  db_name  = "myapp"
  username = "dbadmin"
  password = "supersecret"

  subnet_ids             = ["subnet-abc123", "subnet-def456"]
  vpc_security_group_ids = ["sg-abc123"]

  monitoring_interval = 60
  monitoring_role_arn = "arn:aws:iam::123456789012:role/rds-monitoring-role"

  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  tags = {
    Environment = "prod"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| identifier | Identifier for the RDS instance | string | - | yes |
| engine | Database engine | string | - | yes |
| engine_version | Engine version | string | - | yes |
| instance_class | Instance class | string | - | yes |
| username | Master username | string | - | yes |
| password | Master password | string | - | yes |
| subnet_ids | Subnet IDs for the subnet group | list(string) | - | yes |
| allocated_storage | Allocated storage in GiB | number | 20 | no |
| max_allocated_storage | Max storage for autoscaling (0 to disable) | number | 0 | no |
| storage_type | Storage type (gp2, gp3, io1, standard) | string | gp3 | no |
| storage_encrypted | Enable storage encryption | bool | true | no |
| kms_key_id | KMS key ARN for encryption | string | null | no |
| db_name | Initial database name | string | null | no |
| port | Database port | number | null | no |
| vpc_security_group_ids | VPC security group IDs | list(string) | [] | no |
| publicly_accessible | Make instance publicly accessible | bool | false | no |
| multi_az | Enable Multi-AZ | bool | false | no |
| availability_zone | Availability zone (single-AZ only) | string | null | no |
| create_parameter_group | Create a custom parameter group | bool | false | no |
| parameter_group_family | Parameter group family | string | null | no |
| parameter_group_name | Existing parameter group name | string | null | no |
| parameters | Parameters for the parameter group | list(object) | [] | no |
| backup_retention_period | Backup retention in days | number | 7 | no |
| backup_window | Preferred backup window | string | 03:00-04:00 | no |
| delete_automated_backups | Delete automated backups on deletion | bool | true | no |
| copy_tags_to_snapshot | Copy tags to snapshots | bool | true | no |
| skip_final_snapshot | Skip final snapshot on deletion | bool | false | no |
| maintenance_window | Preferred maintenance window | string | Mon:04:00-Mon:05:00 | no |
| auto_minor_version_upgrade | Enable auto minor version upgrades | bool | true | no |
| allow_major_version_upgrade | Allow major version upgrades | bool | false | no |
| apply_immediately | Apply changes immediately | bool | false | no |
| monitoring_interval | Enhanced monitoring interval in seconds | number | 0 | no |
| monitoring_role_arn | IAM role ARN for enhanced monitoring | string | null | no |
| enabled_cloudwatch_logs_exports | Log types to export to CloudWatch | list(string) | [] | no |
| performance_insights_enabled | Enable Performance Insights | bool | false | no |
| performance_insights_kms_key_id | KMS key ARN for Performance Insights | string | null | no |
| performance_insights_retention_period | Performance Insights retention in days | number | 7 | no |
| deletion_protection | Enable deletion protection | bool | true | no |
| tags | Tags to apply to all resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | ID of the RDS instance |
| instance_arn | ARN of the RDS instance |
| instance_identifier | Identifier of the RDS instance |
| instance_address | Hostname of the RDS instance |
| instance_endpoint | Connection endpoint (host:port) |
| instance_port | Port the instance is listening on |
| db_name | Name of the initial database |
| username | Master username (sensitive) |
| subnet_group_id | ID of the DB subnet group |
| subnet_group_arn | ARN of the DB subnet group |
| parameter_group_id | ID of the custom parameter group |
| parameter_group_arn | ARN of the custom parameter group |

## Supported Engines

| Engine | Example Version | Parameter Group Family |
|--------|----------------|------------------------|
| mysql | 8.0 | mysql8.0 |
| postgres | 15.4 | postgres15 |
| mariadb | 10.11.4 | mariadb10.11 |
| oracle-se2 | 19.0.0.0.ru-2023-07.rur-2023-07.r1 | oracle-se2-19 |
| sqlserver-ex | 15.00.4236.7.v1 | sqlserver-ex-15.0 |

## Notes

- `deletion_protection` defaults to `true` to prevent accidental deletion. Set to `false` before destroying the instance.
- When `skip_final_snapshot` is `false` (default), a final snapshot named `<identifier>-final-snapshot` is created on deletion.
- `monitoring_role_arn` is required when `monitoring_interval` is greater than 0.
- `parameter_group_family` is required when `create_parameter_group` is `true`.
