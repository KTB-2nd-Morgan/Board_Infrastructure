resource "aws_ssm_parameter" "db_url" {
  name  = "/morgan/dev/db/url"
  type  = "SecureString"
  value = var.rds_db_url
}

resource "aws_ssm_parameter" "db_username" {
  name  = "/morgan/dev/db/username"
  type  = "SecureString"
  value = var.rds_db_username
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/morgan/dev/db/password"
  type  = "SecureString"
  value = var.rds_db_password
}

resource "aws_ssm_parameter" "db_name" {
  name  = "/morgan/dev/db/name"
  type  = "String"
  value = var.rds_db_name
}
