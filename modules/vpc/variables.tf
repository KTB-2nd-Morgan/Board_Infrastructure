# VPC
variable "vpc_main_cidr" {
  type = string
}

variable "subnet_public_1" {
  type = string
}

variable "subnet_nat_1" {
  type = string
}

variable "subnet_private_1" {
  type = string
}

# Security Group
# variable "server_port" {
#   type = number
# }

# variable "my_ip" {
#   type = string
# }