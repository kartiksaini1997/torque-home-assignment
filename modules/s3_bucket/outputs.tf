output "bucket_name" {
  value       = aws_s3_bucket.this.bucket
  description = "Created bucket name"
}

output "bucket_arn" {
  value       = aws_s3_bucket.this.arn
  description = "Created bucket ARN"
}

output "region" {
  value       = var.region
  description = "AWS region used"
}
