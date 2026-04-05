variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "log_groups" {
  description = "Map of log group names (key = identifier, value = log group name)"
  type        = map(string)
}

variable "retention_in_days" {
  description = "CloudWatch logs retention in days"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
