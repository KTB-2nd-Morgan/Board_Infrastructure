# 🔐 Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for frontend CloudFront ${var.env}"
}

data "aws_caller_identity" "current" {}

data "aws_acm_certificate" "cert" {
  domain      = "www.morgan.o-r.kr"
  statuses    = ["ISSUED"]
  most_recent = true
  types       = ["AMAZON_ISSUED"]
  provider    = aws.virginia
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}
resource "aws_cloudfront_distribution" "frontend_distribution" {
  enabled             = true
  is_ipv6_enabled     = false
  default_root_object = var.default_root_object
  price_class         = "PriceClass_200" # 북미, 유럽, 아시아, 중동, 아프리카

  aliases = ["www.morgan.o-r.kr"]

  origin {
    domain_name = var.origin_bucket_domain_name
    origin_id   = "s3-frontend-${var.env}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-frontend-${var.env}"

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Name = "frontend-cloudfront-${var.env}"
  }
}

resource "aws_s3_bucket_policy" "frontend_policy" {
  bucket = var.frontend_bucket_id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement : [
      {
        Sid : "AllowCloudFrontServicePrincipalReadOnly",
        Effect : "Allow",
        Principal : {
          Service : "cloudfront.amazonaws.com"
        },
        Action : "s3:GetObject",
        Resource : "${var.frontend_bucket_arn}/*",
        Condition : {
          StringEquals : {
            "AWS:SourceArn" : "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.frontend_distribution.id}"
          }
        }
      }
    ]
  })
}
