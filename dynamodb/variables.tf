variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "billing_mode" {
  description = "Billing mode for the table (PROVISIONED or PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PROVISIONED", "PAY_PER_REQUEST"], var.billing_mode)
    error_message = "Billing mode must be either PROVISIONED or PAY_PER_REQUEST."
  }
}

variable "hash_key" {
  description = "Hash key (partition key) for the table"
  type        = string
}

variable "range_key" {
  description = "Range key (sort key) for the table"
  type        = string
  default     = null
}

variable "attributes" {
  description = "List of attribute definitions (name and type)"
  type = list(object({
    name = string
    type = string
  }))
}

variable "read_capacity" {
  description = "Read capacity units (only used if billing_mode is PROVISIONED)"
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "Write capacity units (only used if billing_mode is PROVISIONED)"
  type        = number
  default     = 5
}

variable "ttl_enabled" {
  description = "Enable TTL (Time To Live)"
  type        = bool
  default     = false
}

variable "ttl_attribute_name" {
  description = "Attribute name for TTL"
  type        = string
  default     = "ttl"
}

variable "point_in_time_recovery" {
  description = "Enable point-in-time recovery"
  type        = bool
  default     = false
}

variable "encryption_enabled" {
  description = "Enable server-side encryption"
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption (if encryption_enabled is true)"
  type        = string
  default     = null
}

variable "global_secondary_indexes" {
  description = "List of global secondary indexes"
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = optional(string)
    projection_type    = string
    non_key_attributes = optional(list(string))
    read_capacity      = optional(number)
    write_capacity     = optional(number)
  }))
  default = []
}

variable "local_secondary_indexes" {
  description = "List of local secondary indexes"
  type = list(object({
    name               = string
    range_key          = string
    projection_type    = string
    non_key_attributes = optional(list(string))
  }))
  default = []
}

variable "stream_enabled" {
  description = "Enable DynamoDB Streams"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "Stream view type (KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES)"
  type        = string
  default     = "NEW_AND_OLD_IMAGES"

  validation {
    condition     = contains(["KEYS_ONLY", "NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES"], var.stream_view_type)
    error_message = "Stream view type must be one of: KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES."
  }
}

variable "tags" {
  description = "Tags to apply to the table"
  type        = map(string)
  default     = {}
}
