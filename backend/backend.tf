resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-dev-morgan"
  force_destroy = false

  tags = {
    Name = "terraform-state-dev-morgan"
  }
}

resource "aws_s3_bucket_versioning" "versioning_enable" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
    }
  }  
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "terraform_state_policy" {
  bucket = aws_s3_bucket.terraform_state.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:GetBucketPolicy",
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::terraform-state-dev-morgan",
        "arn:aws:s3:::terraform-state-dev-morgan/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "terraform-state-lock-dev-morgan"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name = "terraform-state-lock-dev-morgan"
  }
  
}