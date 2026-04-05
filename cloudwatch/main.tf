# ========================
# CloudWatch Module
# Creates CloudWatch Log Groups
# ========================

resource "aws_cloudwatch_log_group" "log_groups" {
  for_each = var.log_groups

  name              = each.value
  retention_in_days = var.retention_in_days

  tags = merge(
    var.tags,
    {
      Name        = each.key
      Environment = var.environment
    }
  )
}
