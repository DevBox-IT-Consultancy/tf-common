variable "identifier" {
  description = "Identifier for the RDS instance. Must start with a letter, contain only lowercase letters, numbers, and hyphens, and be 1–63 characters long."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,62}$", var.identifier))
    error_message = "RDS identifier must start with a letter, contain only lowercase letters, numbers, and hyphens, and be at most 63 characters long."
  }
}

# ========================
# Engine
# ========================
variable "engine" {
  description = "Database engine (e.g. mysql, postgres, mariadb, oracle-se2, sqlserver-ex)"
  type        = string
}

variable "engine_version" {
  description = "Version of the database engine"
  type        = string
}

variable "instance_class" {
  description = "Instance class for the RDS instance (e.g. db.t3.micro)"
  type        = string
}

# ========================
# Storage
# ========================
variable "allocated_storage" {
  description = "Allocated storage in GiB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum storage in GiB for autoscaling (0 to disable)"
  type        = number
  default     = 0
}

variable "storage_type" {
  description = "Storage type (gp2, gp3, io1, standard)"
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp2", "gp3", "io1", "standard"], var.storage_type)
    error_message = "Storage type must be one of: gp2, gp3, io1, standard."
  }
}

variable "storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ARN for storage encryption (uses default AWS key if null)"
  type        = string
  default     = null
}

# ========================
# Database
# ========================
variable "db_name" {
  description = "Name of the initial database to create"
  type        = string
  default     = null
}

variable "username" {
  description = "Master username for the database"
  type        = string
}

variable "password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
}

variable "port" {
  description = "Port on which the database accepts connections (defaults to engine default if null)"
  type        = number
  default     = null
}

# ========================
# Network
# ========================
variable "subnet_ids" {
  description = "List of subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs to associate"
  type        = list(string)
  default     = []
}

variable "publicly_accessible" {
  description = "Make the instance publicly accessible"
  type        = bool
  default     = false
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false
}

variable "availability_zone" {
  description = "Availability zone for the instance (ignored when multi_az is true)"
  type        = string
  default     = null
}

# ========================
# Parameter Group
# ========================
variable "create_parameter_group" {
  description = "Create a custom parameter group"
  type        = bool
  default     = false
}

variable "parameter_group_family" {
  description = "Parameter group family (e.g. mysql8.0, postgres15)"
  type        = string
  default     = null
}

variable "parameter_group_name" {
  description = "Name of an existing parameter group to use (when create_parameter_group is false)"
  type        = string
  default     = null
}

variable "parameters" {
  description = "List of parameters to apply to the parameter group"
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "immediate")
  }))
  default = []
}

# ========================
# Backup
# ========================
variable "backup_retention_period" {
  description = "Number of days to retain automated backups (0 to disable)"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Preferred backup window (e.g. 03:00-04:00)"
  type        = string
  default     = "03:00-04:00"
}

variable "delete_automated_backups" {
  description = "Delete automated backups when the instance is deleted"
  type        = bool
  default     = true
}

variable "copy_tags_to_snapshot" {
  description = "Copy tags to snapshots"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion"
  type        = bool
  default     = false
}

# ========================
# Maintenance
# ========================
variable "maintenance_window" {
  description = "Preferred maintenance window (e.g. Mon:04:00-Mon:05:00)"
  type        = string
  default     = "Mon:04:00-Mon:05:00"
}

variable "auto_minor_version_upgrade" {
  description = "Enable automatic minor version upgrades"
  type        = bool
  default     = true
}

variable "allow_major_version_upgrade" {
  description = "Allow major version upgrades"
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Apply changes immediately instead of during the next maintenance window"
  type        = bool
  default     = false
}

# ========================
# Monitoring
# ========================
variable "monitoring_interval" {
  description = "Enhanced monitoring interval in seconds (0 to disable, valid: 0, 1, 5, 10, 15, 30, 60)"
  type        = number
  default     = 0

  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.monitoring_interval)
    error_message = "Monitoring interval must be one of: 0, 1, 5, 10, 15, 30, 60."
  }
}

variable "monitoring_role_arn" {
  description = "IAM role ARN for enhanced monitoring (required when monitoring_interval > 0)"
  type        = string
  default     = null
}

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to export to CloudWatch (e.g. [\"audit\", \"error\", \"general\", \"slowquery\"])"
  type        = list(string)
  default     = []
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
  default     = false
}

variable "performance_insights_kms_key_id" {
  description = "KMS key ARN for Performance Insights encryption"
  type        = string
  default     = null
}

variable "performance_insights_retention_period" {
  description = "Retention period for Performance Insights data in days (7 or 731)"
  type        = number
  default     = 7

  validation {
    condition     = contains([7, 731], var.performance_insights_retention_period)
    error_message = "Performance Insights retention period must be 7 or 731 days."
  }
}

# ========================
# Deletion Protection
# ========================
variable "deletion_protection" {
  description = "Enable deletion protection"
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
