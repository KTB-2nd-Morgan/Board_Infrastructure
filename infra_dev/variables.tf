# Common
variable "region" {
  type    = string
  default = "ap-northeast-2"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "az" {
  type    = list(string)
  default = ["ap-northeast-2a"]

}

# VPC
variable "vpc_main_cidr" {
  type    = string
  default = "192.168.0.0/16"
}

variable "subnet_public_1" {
  type    = string
  default = "192.168.10.0/24"
}

variable "subnet_nat_1" {
  type    = string
  default = "192.168.20.0/24"
}

variable "subnet_private_1" {
  type    = string
  default = "192.168.30.0/24"
}

# EC2
variable "ami" {
  type    = string
  default = "ami-062cddb9d94dcf95d" #AL 2023
}
variable "instance_type" {
  type    = string
  default = "t2.micro"

}

variable "ebs_type" {
  type    = string
  default = "gp2"
}

variable "instance_ebs_size" {
  type    = number
  default = 30
}

variable "key_name" {
  type    = string
  default = "morgan-dev"
}

# RDS
variable "dbname" {
  type    = string
  default = "morgan-dev"
}

variable "engine" {
  type    = string
  default = "mysql"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "sg_allow_ingress_list_mysql" {
  type    = list(any)
  default = []
}

variable "rds_instance_count" {
  type    = number
  default = 1
}

variable "rds_instance_class" {
  type    = string
  default = "db.t3.micro"
}
