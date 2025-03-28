variable "alarm_topic_arn" {
  description = "SNS topic ARN for alarm notifications"
  type        = string
}

variable "slack_webhook_url" {
  description = "Slack webhook URL for sending notifications"
  type        = string
}
