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
  subnet_nat_1     = var.subnet_nat_1
  subnet_private_1 = var.subnet_private_1
  subnet_private_2 = var.subnet_private_2
}

# Security Group
resource "aws_security_group" "sg_ec2" {
  vpc_id = module.vpc.vpc_id
  name   = "sg_ec2"
  ingress = [
    {
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      description      = ""
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
}

# EC2
module "ec2_instance" {
  source                     = "../modules/ec2"
  instance_type              = var.instance_type
  ebs_type                   = var.ebs_type
  instance_ebs_size          = var.instance_ebs_size
  key_name                   = var.key_name
  sg_ec2_ids                 = [aws_security_group.sg_ec2.id]
  instance_subnet_id_nat     = module.vpc.subnet_nat_1.id    # NAT 인스턴스용 서브넷
  instance_subnet_id_openvpn = module.vpc.subnet_public_1.id # OpenVPN 인스턴스용 서브넷
  ami                        = var.ami                       # NAT 인스턴스용 AMI (예: AL2023)
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
