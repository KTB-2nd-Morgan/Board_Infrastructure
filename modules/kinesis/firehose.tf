# Firehose IAM Role
resource "aws_iam_role" "firehose_role" {
  name = "firehose_delivery_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "firehose.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# Firehose Delivery Stream
resource "aws_cloudwatch_log_group" "firehose_error_logs" {
  name              = "/aws/kinesisfirehose/morgan-log-delivery"
  retention_in_days = 7
}

resource "aws_kinesis_firehose_delivery_stream" "log_delivery" {
  name        = "morgan-log-delivery"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.firehose_role.arn
    bucket_arn         = var.s3_bucket_arn
    buffering_size     = 1
    buffering_interval = 60
    compression_format = "UNCOMPRESSED"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.firehose_error_logs.name
      log_stream_name = "delivery-errors"
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.firehose_error_logs,
    aws_iam_role.firehose_role
  ]
}

# Firehose IAM Policy
resource "aws_iam_policy" "firehose_policy" {
  name = "firehose_s3_access_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetBucketLocation"
        ],
        Resource = "${var.s3_bucket_arn}/*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:PutLogEvents",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ],
        Resource = "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/kinesisfirehose/*"
      },
      {
        Effect = "Allow",
        Action = [
          "firehose:PutRecord",
          "firehose:PutRecordBatch"
        ],
        Resource = aws_kinesis_firehose_delivery_stream.log_delivery.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_firehose_policy" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.firehose_policy.arn
}

# CloudWatch to Firehose IAM Role
resource "aws_iam_role" "cloudwatch_logs_to_firehose" {
  name = "cloudwatch-logs-to-firehose"

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

resource "aws_iam_policy" "logs_to_firehose_policy" {
  name = "logs-to-firehose"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "firehose:PutRecord",
          "firehose:PutRecordBatch"
        ],
        Resource = aws_kinesis_firehose_delivery_stream.log_delivery.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_logs_to_firehose_policy" {
  role       = aws_iam_role.cloudwatch_logs_to_firehose.name
  policy_arn = aws_iam_policy.logs_to_firehose_policy.arn
}

# Subscription Filter
resource "aws_cloudwatch_log_subscription_filter" "backend_to_firehose" {
  name            = "backend-log-subscription"
  log_group_name  = var.backend_log_group_name
  filter_pattern  = ""
  destination_arn = aws_kinesis_firehose_delivery_stream.log_delivery.arn
  role_arn        = aws_iam_role.cloudwatch_logs_to_firehose.arn

  depends_on = [
    aws_kinesis_firehose_delivery_stream.log_delivery,
    aws_iam_role_policy_attachment.attach_logs_to_firehose_policy
  ]
}
