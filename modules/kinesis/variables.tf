variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket to deliver logs to"
  type        = string
}

variable "backend_log_group_name" {
  description = "Name of the backend log group"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"

}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
  default     = "418295722497"
}
