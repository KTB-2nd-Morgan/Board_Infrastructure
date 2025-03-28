variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket to deliver logs to"
  type        = string
}

variable "backend_log_group_name" {
  description = "Name of the backend log group"
  type        = string
}
