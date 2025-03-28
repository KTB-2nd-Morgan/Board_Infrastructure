resource "aws_sns_topic" "alarm_topic" {
  name = "cloudwatch-error-alarm-topic"
}

# CloudWatch Log Subscription Filter(Error)
resource "aws_cloudwatch_log_metric_filter" "error_filter" {
  name           = "ErrorFilter"
  log_group_name = "/morgan/backend"
  pattern        = "?ERROR ?Exception"

  metric_transformation {
    name      = "BackendErrorCount"
    namespace = "MorganBackend"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "error_alarm" {
  alarm_name          = "BackendErrorAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "BackendErrorCount"
  namespace           = "MorganBackend"
  period              = 60
  statistic           = "Sum"
  threshold           = 1

  alarm_description = "Triggered when backend ERROR log appears"
  alarm_actions     = [aws_sns_topic.alarm_topic.arn]
}
