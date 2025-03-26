variable "origin_bucket_domain_name" {
  description = "S3 origin bucket domain name"
  type        = string
}

variable "frontend_bucket_id" {
  description = "S3 frontend bucket id"
  type        = string
}

variable "frontend_bucket_arn" {
  description = "S3 frontend bucket arn"
  type        = string
}

variable "default_root_object" {
  description = "Default root object for CloudFront"
  type        = string
  default     = "index.html"
}

variable "env" {
  type = string
}
