terraform {
 required_version = ">= 1.0.0, < 2.0.0"

  backend "s3" {
    bucket = "terraform-state-dev-morgan"
    key  = "dev/terraform/terraform.tfstate"
    region = "ap-northeast-2"
    encrypt = true
    dynamodb_table = "terraform-state-lock-dev-morgan"
  }
}

# VPC
module "vpc" {
  source = "../modules/vpc"
  vpc_main_cidr = var.vpc_main_cidr
    subnet_public_1 = var.subnet_public_1
    subnet_nat_1 = var.subnet_nat_1
    subnet_private_1 = var.subnet_private_1
}