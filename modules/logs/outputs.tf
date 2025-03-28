output "log_bucket_arn" {
  value = aws_s3_bucket.log_bucket.arn
}

output "backend_log_group_name" {
  value = aws_cloudwatch_log_group.backend_logs.name
}
