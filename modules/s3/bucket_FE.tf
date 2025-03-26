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

resource "aws_s3_bucket_versioning" "frontend_versioning" {
  bucket = aws_s3_bucket.frontend.id

  versioning_configuration {
    status = "Enabled"
  }
}
