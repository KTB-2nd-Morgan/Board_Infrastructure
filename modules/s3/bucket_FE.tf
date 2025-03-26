resource "aws_s3_bucket" "frontend" {
  bucket = var.frontend_bucket_name

  website {
    index_document = var.default_root_object
    error_document = var.default_root_object
  }

  tags = {
    Name = "frontend-${var.env}"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend_public_access" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "frontend_policy" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = "*"
      Action    = ["s3:GetObject"]
      Resource  = "${aws_s3_bucket.frontend.arn}/*"
    }]
  })
}
