output "cloudfront_domain" {
  value = aws_cloudfront_distribution.frontend_distribution.domain_name
}
