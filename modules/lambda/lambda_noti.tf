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

# Lambda Permission for SNS
resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.slack_alert.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.alarm_topic_arn
}

resource "aws_sns_topic_subscription" "lambda_sub" {
  topic_arn = var.alarm_topic_arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.slack_alert.arn
}

