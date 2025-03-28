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
resource "aws_kinesis_firehose_delivery_stream" "log_delivery" {
  name        = "morgan-log-delivery"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.firehose_role.arn
    bucket_arn         = var.s3_bucket_arn
    buffering_size     = 5  # MB 단위 (1~128 MB)
    buffering_interval = 60 # 초 단위 (60~900초)
    compression_format = "GZIP"
  }

  depends_on = [aws_iam_role.firehose_role]
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
          "logs:GetLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutSubscriptionFilter",
          "logs:DeleteSubscriptionFilter"
        ],
        Resource = "*"
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

# Attach Firehose Policy to Role
resource "aws_iam_role_policy_attachment" "attach_firehose_policy" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.firehose_policy.arn
}


# 
resource "aws_cloudwatch_log_subscription_filter" "backend_to_firehose" {
  name            = "backend-log-subscription"
  log_group_name  = var.backend_log_group_name
  filter_pattern  = ""
  destination_arn = aws_kinesis_firehose_delivery_stream.log_delivery.arn
  role_arn        = aws_iam_role.firehose_role.arn
  depends_on      = [aws_kinesis_firehose_delivery_stream.log_delivery, aws_iam_role_policy_attachment.attach_firehose_policy]
}
