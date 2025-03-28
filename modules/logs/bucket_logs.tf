# S3 Bucket for Logs
resource "aws_s3_bucket" "log_bucket" {
  bucket = "morgan-log-bucket"

  tags = {
    Name        = "log-bucket"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_versioning" "log_bucket_versioning" {
  bucket = aws_s3_bucket.log_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "log_bucket_encryption" {
  bucket = aws_s3_bucket.log_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "frontend_logs" {
  name              = "/morgan/frontend"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "backend_logs" {
  name              = "/morgan/backend"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "backend_spring_logs" {
  name              = "/morgan/backend/spring-app"
  retention_in_days = 14
}

# resource "aws_iam_role" "cloudwatch_to_s3" {
#   name = "cloudwatch-to-s3-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         Service = "logs.${var.aws_region}.amazonaws.com"
#       }
#       Action = "sts:AssumeRole"
#     }]
#   })
# }

# resource "aws_iam_policy" "cloudwatch_s3_policy" {
#   name = "cloudwatch-s3-access"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:PutObject",
#           "s3:GetBucketLocation"
#         ]
#         Resource = [
#           "${aws_s3_bucket.log_bucket.arn}/*"
#         ]
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "attach_cloudwatch_s3_policy" {
#   role       = aws_iam_role.cloudwatch_to_s3.name
#   policy_arn = aws_iam_policy.cloudwatch_s3_policy.arn
# }

resource "aws_s3_bucket_policy" "allow_firehose_write" {
  bucket = aws_s3_bucket.log_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowFirehoseWriteAccess",
        Effect = "Allow",
        Principal = {
          Service = "firehose.amazonaws.com"
        },
        Action = [
          "s3:PutObject"
        ],
        Resource = "${aws_s3_bucket.log_bucket.arn}/*",
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.aws_account_id
          }
        }
      }
    ]
  })
}
