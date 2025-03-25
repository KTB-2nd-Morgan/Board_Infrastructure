variable "env" {
  type    = string
  default = "dev"
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "sg_allow_comm_list" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "port" {
  type    = number
  default = 80
}

variable "target_type" {
  type    = string
  default = "instance" # 또는 "ip"
}

variable "hc_path" {
  type    = string
  default = "/"
}

variable "hc_interval" {
  type    = number
  default = 30
}

variable "hc_timeout" {
  type    = number
  default = 10
}

variable "hc_healthy_threshold" {
  type    = number
  default = 3
}

variable "hc_unhealthy_threshold" {
  type    = number
  default = 5
}

variable "hc_matcher" {
  type    = string
  default = "200-399"
}

variable "internal" {
  type    = bool
  default = false
}

variable "idle_timeout" {
  type    = number
  default = 60
}

variable "aws_s3_lb_logs_name" {
  type = string
}

# variable "ssl_policy" {
#   type    = string
#   default = "ELBSecurityPolicy-2016-08"
# }

# variable "certificate_arn" {
#   type = string
# }

variable "instance_ids" {
  type = list(string)
}

variable "availability_zone" {
  type = string
}

