output "instance_id" {
  description = "ID of the RDS instance"
  value       = aws_db_instance.this.id
}

output "instance_arn" {
  description = "ARN of the RDS instance"
  value       = aws_db_instance.this.arn
}

output "instance_identifier" {
  description = "Identifier of the RDS instance"
  value       = aws_db_instance.this.identifier
}

output "instance_address" {
  description = "Hostname of the RDS instance"
  value       = aws_db_instance.this.address
}

output "instance_endpoint" {
  description = "Connection endpoint of the RDS instance (host:port)"
  value       = aws_db_instance.this.endpoint
}

output "instance_port" {
  description = "Port the RDS instance is listening on"
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Name of the initial database"
  value       = aws_db_instance.this.db_name
}

output "username" {
  description = "Master username of the RDS instance"
  value       = aws_db_instance.this.username
  sensitive   = true
}

output "subnet_group_id" {
  description = "ID of the DB subnet group"
  value       = aws_db_subnet_group.this.id
}

output "subnet_group_arn" {
  description = "ARN of the DB subnet group"
  value       = aws_db_subnet_group.this.arn
}

output "parameter_group_id" {
  description = "ID of the custom parameter group (if created)"
  value       = var.create_parameter_group ? aws_db_parameter_group.this[0].id : null
}

output "parameter_group_arn" {
  description = "ARN of the custom parameter group (if created)"
  value       = var.create_parameter_group ? aws_db_parameter_group.this[0].arn : null
}
