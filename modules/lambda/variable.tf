variable "slack_webhook_url" {
  description = "Slack webhook URL for sending notifications"
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
