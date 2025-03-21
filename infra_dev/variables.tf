variable "region" {
  type = string
  default = "ap-northeast-2"
}

variable "vpc_main_cidr" {
  type = string
  default = "192.168.0.0/16"
}

variable "subnet_public_1" {
  type = string
  default = "192.168.10.0/24"
}

variable "subnet_nat_1" {
  type = string
  default = "192.168.20.0/24"
}

variable "subnet_private_1" {
  type = string
  default = "192.168.30.0/24"
}

# variable "server_port" {
#   type = number
#   default = 80
# }

# variable "my_ip" {
#   type = string
#   default = "0.0.0.0/0"
# }