variable "slack_webhook_url" {
  description = "Slack webhook URL for sending notifications"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"

}
