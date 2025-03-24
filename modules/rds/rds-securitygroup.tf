resource "aws_security_group" "sg-mysql" {
  name   = "rds-sg-mysql-${var.dbname}"
  vpc_id = var.network_vpc_id

  ingress {
    description = ""
    from_port   = 3306
    to_port     = 3306
    protocol    = "TCP"
    cidr_blocks = var.sg_allow_ingress_list_mysql
  }

  ingress {
    description     = "Allow MySQL access from specific security groups(public subnet-sg)"
    from_port       = 3306
    to_port         = 3306
    protocol        = "TCP"
    security_groups = var.sg_allow_ingress_sg_list_mysql
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # 모든 프로토콜 허용
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(tomap({
    Name = "sg-mysql-${var.dbname}" }),
  var.tags)
}
