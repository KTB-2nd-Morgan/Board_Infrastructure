output "s3_bucket_name" {
  value = aws_s3_bucket.frontend.bucket
}

output "s3_bucket_id" {
  value = aws_s3_bucket.frontend.id
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.frontend.arn
}
