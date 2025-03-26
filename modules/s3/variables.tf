variable "env" {
  type = string
}

variable "frontend_bucket_name" {
  type    = string
  default = "www.morgan.o-r.kr"
}

variable "default_root_object" {
  description = "Default root object for CloudFront"
  type        = string
  default     = "index.html"
}
