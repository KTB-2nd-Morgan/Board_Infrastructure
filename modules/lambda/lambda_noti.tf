# IAM Role and Policy for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda-slack-alert-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy_attachment" "lambda_logs_policy" {
  name       = "lambda-logs"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ✅ CloudWatch Logs → Lambda 트리거용 IAM Role
resource "aws_iam_role" "cloudwatch_logs_to_lambda" {
  name = "cloudwatch-logs-to-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "logs.${var.aws_region}.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy_attachment" "attach_logs_to_lambda_policy" {
  name       = "logs-to-lambda"
  roles      = [aws_iam_role.cloudwatch_logs_to_lambda.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Function for Slack Notifications
resource "aws_lambda_function" "slack_alert" {
  filename      = "${path.module}/slack-alert.zip"
  function_name = "slackAlertFunction"
  role          = aws_iam_role.lambda_role.arn
  handler       = "slack-alert.lambda_handler"
  runtime       = "python3.9"

  environment {
    variables = {
      SLACK_WEBHOOK_URL = var.slack_webhook_url
    }
  }

  source_code_hash = filebase64sha256("${path.module}/slack-alert.zip")
}


# ✅ CloudWatch Logs → Lambda 연결을 위한 Subscription Filter
resource "aws_cloudwatch_log_subscription_filter" "error_direct_to_lambda" {
  name            = "ErrorToSlack"
  log_group_name  = "/morgan/backend/spring-app"
  filter_pattern  = "?ERROR ?Exception"
  destination_arn = aws_lambda_function.slack_alert.arn

  depends_on = [
    aws_lambda_function.slack_alert,
    aws_iam_policy_attachment.attach_logs_to_lambda_policy
  ]
}
