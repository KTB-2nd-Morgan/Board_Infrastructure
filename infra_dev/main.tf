terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  backend "s3" {
    bucket         = "terraform-state-dev-morgan"
    key            = "dev/terraform/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock-dev-morgan"
  }
}

# VPC
module "vpc" {
  source           = "../modules/vpc"
  vpc_main_cidr    = var.vpc_main_cidr
  subnet_public_1  = var.subnet_public_1
  subnet_public_2  = var.subnet_public_2
  subnet_nat_1     = var.subnet_nat_1
  subnet_nat_2     = var.subnet_nat_2
  subnet_private_1 = var.subnet_private_1
  subnet_private_2 = var.subnet_private_2
}

# Security Group
resource "aws_security_group" "sg_ec2" {
  vpc_id = module.vpc.vpc_id
  name   = "sg_ec2"
  ingress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      description      = ""
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      description      = ""
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
}

# IAM - EC2
resource "aws_iam_instance_profile" "codedeploy_profile" {
  name = "CodeDeploy-EC2-Profile"
  role = var.codedeploy_ec2_role
}

# EC2 - NAT
module "ec2_nat_instance" {
  source                 = "../modules/ec2_nat"
  instance_type          = var.instance_type
  ebs_type               = var.ebs_type
  instance_ebs_size      = var.instance_ebs_size
  key_name               = var.key_name
  sg_ec2_ids             = [aws_security_group.sg_ec2.id]
  instance_subnet_id_nat = module.vpc.subnet_nat_1.id # NAT 인스턴스용 서브넷
  ami                    = var.ami                    # NAT 인스턴스용 AMI (예: AL2023)
  env                    = var.env
  iam_instance_profile   = aws_iam_instance_profile.codedeploy_profile.name
  depends_on             = [module.vpc]
}

# EC2 - OpenVPN
module "openvpn_instance" {
  source                     = "../modules/ec2_openvpn"
  instance_type              = var.instance_type
  ebs_type                   = var.ebs_type
  instance_ebs_size          = var.instance_ebs_size
  key_name                   = var.key_name
  sg_ec2_ids                 = [aws_security_group.sg_ec2.id]
  instance_subnet_id_openvpn = module.vpc.subnet_public_1.id # OpenVPN 인스턴스용 서브넷
  openvpn_password           = var.openvpn_password          # OpenVPN 인스턴스용 비밀번호
  env                        = var.env

  depends_on = [module.vpc]
}

# RDS
module "rds_mysql" {
  source = "../modules/rds"

  dbname                         = var.dbname
  engine                         = var.engine
  db_password                    = var.db_password
  az                             = var.az
  subnet_ids                     = [module.vpc.subnet_private_1.id, module.vpc.subnet_private_2.id]
  network_vpc_id                 = module.vpc.vpc_id
  sg_allow_ingress_list_mysql    = var.sg_allow_ingress_list_mysql
  sg_allow_ingress_sg_list_mysql = [aws_security_group.sg_ec2.id]
  rds_instance_count             = var.rds_instance_count
  rds_instance_class             = var.rds_instance_class

  depends_on = [module.vpc, aws_security_group.sg_ec2]
}

# ALB - logs
# resource "aws_s3_bucket" "alb_logs" {
#   bucket = var.aws_s3_lb_logs_name

#   tags = {
#     Name = var.aws_s3_lb_logs_name
#     Env  = var.env
#   }
# }

# ALB
module "alb" {
  source     = "../modules/alb"
  env        = var.env
  vpc_id     = module.vpc.vpc_id
  subnet_ids = [module.vpc.subnet_public_1.id, module.vpc.subnet_public_2.id]
  # aws_s3_lb_logs_name = var.aws_s3_lb_logs_name
  port = var.port

  # ALB 타깃 그룹에 등록할 인스턴스 ID 리스트
  instance_ids      = [module.ec2_nat_instance.nat_instance_id]
  availability_zone = var.availability_zone # 타깃 그룹 어태치먼트에 사용되는 가용 영역

  depends_on = [module.ec2_nat_instance]
}


# ECR
module "ecr" {
  source = "../modules/ecr"
  name   = "spring-app"
  tags = {
    Name = "spring-app-${var.env}"
  }
}

# CodeDeploy
module "codedeploy" {
  source                        = "../modules/code_deploy"
  application_name              = var.server_application_name
  deployment_group_backend_name = var.server_deployment_group_name
  service_role_arn              = var.codedeploy_service_role_arn
  ec2_tag_key                   = "Name"
  ec2_tag_value                 = module.ec2_nat_instance.nat_instance_name

  depends_on = [module.ecr, module.alb]
}


# S3
module "s3-frontend" {
  source = "../modules/s3"
  env    = var.env
}

# CloudFront
module "cloudfront-frontend" {
  source               = "../modules/cloudfront"
  env                  = var.env
  frontend_bucket_name = module.s3-frontend.s3_bucket_name
  frontend_bucket_id   = module.s3-frontend.s3_bucket_id
  frontend_bucket_arn  = module.s3-frontend.s3_bucket_arn
}

# SSM - Parameter Store
module "ssm-parameter" {
  source          = "../modules/ssm"
  rds_db_url      = var.rds_db_url
  rds_db_name     = var.rds_db_name
  rds_db_password = var.rds_db_password
  rds_db_username = var.rds_db_username
}

# Logs
module "logs" {
  source = "../modules/logs"
}

# Kinesis
module "kinesis" {
  source                 = "../modules/kinesis"
  s3_bucket_arn          = module.logs.log_bucket_arn
  backend_log_group_name = module.logs.backend_log_group_name
}

# # AWS SNS
# module "notification" {
#   source = "../modules/notification"
# }

# AWS Lambda
module "notification_lambda" {
  source            = "../modules/lambda"
  slack_webhook_url = var.slack_webhook_url
}
