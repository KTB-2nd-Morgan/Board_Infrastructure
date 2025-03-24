variable "tags" {
  type = map(string)
  default = {
    "name" = "morgan-dev-db"
  }
}

variable "dbname" {
  type    = string
  default = "morgan-dev"
}

variable "engine" {
  type    = string
  default = "mysql"
}

variable "db_username" {
  type    = string
  default = "root"
}

# 민감한 DB 비밀번호 – 실제 배포 시 secrets이나 별도의 파일로 관리
variable "db_password" {
  type      = string
  sensitive = true
}

variable "port" {
  type    = number
  default = 3306 #mysql
}

##Network (all required)
variable "az" {
  type = list(string)
}
variable "subnet_ids" {
  type = list(string)
}

variable "network_vpc_id" {
  type = string
}

variable "sg_allow_ingress_list_mysql" {
  type    = list(any)
  default = []
}
variable "sg_allow_ingress_sg_list_mysql" {
  type    = list(any)
  default = []
}

##RDS instance
variable "rds_instance_count" {
  type    = number
  default = 0
}

variable "rds_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "storage_size" {
  type    = number
  default = 20
}

variable "rds_instance_auto_minor_version_upgrade" {
  type    = bool
  default = false
}

variable "rds_instance_publicly_accessible" {
  type    = bool
  default = false
}
