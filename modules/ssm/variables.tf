variable "rds_db_url" {
  type = string
}

variable "rds_db_name" {
  type = string
}

variable "rds_db_username" {
  type    = string
  default = "root"
}

variable "rds_db_password" {
  type = string
}
