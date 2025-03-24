resource "aws_db_subnet_group" "mysql_subnet_group" {
  name       = "rds-subnet-group-${var.dbname}"
  subnet_ids = var.subnet_ids

  tags = merge({
    Name = "rds-subnet-group-${var.dbname}"
  }, var.tags)
}

resource "aws_db_instance" "mysql_instance" {
  # rds_instance_count가 0일 경우 기본적으로 1개 인스턴스를 생성
  count = var.rds_instance_count > 0 ? var.rds_instance_count : 1

  identifier                 = var.dbname
  engine                     = var.engine             # "mysql"
  instance_class             = var.rds_instance_class # 예: "db.t3.micro"
  allocated_storage          = var.storage_size       # 저장소 용량 (GB) – 필요에 따라 조정
  username                   = var.db_username
  password                   = var.db_password # 민감한 값, 별도로 변수로 정의 (sensitive=true)
  port                       = var.port        # 3306
  publicly_accessible        = var.rds_instance_publicly_accessible
  auto_minor_version_upgrade = var.rds_instance_auto_minor_version_upgrade
  db_subnet_group_name       = aws_db_subnet_group.mysql_subnet_group.name

  vpc_security_group_ids = var.sg_allow_ingress_sg_list_mysql

  skip_final_snapshot = true

  tags = merge({
    Name = "mysql-instance-${var.dbname}"
  }, var.tags)
}
