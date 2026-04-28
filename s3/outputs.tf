output "bucket_id" {
  description = "Name (ID) of the S3 bucket"
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.this.arn
}

output "bucket_name" {
  description = "Name of the S3 bucket (same as bucket_id)"
  value       = aws_s3_bucket.this.bucket
}

output "bucket_domain_name" {
  description = "Bucket domain name (e.g. bucket.s3.amazonaws.com)"
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "Regional bucket domain name (e.g. bucket.s3.ap-southeast-1.amazonaws.com)"
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}

output "bucket_region" {
  description = "AWS region the bucket was created in"
  value       = aws_s3_bucket.this.region
}

output "hosted_zone_id" {
  description = "Route 53 hosted zone ID for the bucket's region (useful for alias records)"
  value       = aws_s3_bucket.this.hosted_zone_id
}
