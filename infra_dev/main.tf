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

# VPC 생성
resource "aws_vpc" "project_vpc" {
  cidr_block = var.vpc_main_cidr
  enable_dns_hostnames = true
  instance_tenancy = "default"
  tags = {
    Name = "vpc_morgan_project"
  }
  
}

# Public Subnet 생성
resource "aws_subnet" "public_subnet_1" {
  vpc_id = aws_vpc.project_vpc.id
  cidr_block = cidrsubnet(aws_vpc.project_vpc.cidr_block, 8, 10)
  availability_zone = "ap-northeast-2a"
#   map_public_ip_on_launch = true
  tags = {
    Name = "subnet_public_1"
  }
}

# NAT Subnet 생성
resource "aws_subnet" "nat_subnet_1" {
  vpc_id = aws_vpc.project_vpc.id
  cidr_block = cidrsubnet(aws_vpc.project_vpc.cidr_block, 8, 20)
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "subnet_nat_1"
  }
}

resource "aws_subnet" "nat_subnet_2" {
  vpc_id = aws_vpc.project_vpc.id
  cidr_block = cidrsubnet(aws_vpc.project_vpc.cidr_block, 8, 30)
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "subnet_nat_2"
  }
}

# Private Subnet 생성
resource "aws_subnet" "private_subnet_1" {
  vpc_id = aws_vpc.project_vpc.id
  cidr_block = cidrsubnet(aws_vpc.project_vpc.cidr_block, 8, 40)
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "subnet_private_1"
  }
}

# 인터넷 게이트웨이 생성
resource "aws_internet_gateway" "project_igw" {
  vpc_id = aws_vpc.project_vpc.id
  tags = {
    Name = "igw_project"
  }
}

# EIP 생성
resource "aws_eip" "nat_eip_azone" {
  domain = "vpc"
}

# NAT 게이트웨이 생성
resource "aws_nat_gateway" "project_nat_azone" {
  allocation_id = aws_eip.nat_eip_azone.id
  subnet_id = aws_subnet.public_subnet_1.id

  depends_on = [ aws_internet_gateway.project_igw, aws_subnet.public_subnet_1 ]

  tags = {
    Name = "nat_azone"
  }
}

# 라우팅 테이블 생성
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.project_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project_igw.id
  }

  tags = {
    Name = "rt_public"
  }
}

resource "aws_route_table" "nat_rt_1" {
  vpc_id = aws_vpc.project_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.project_nat_azone.id
  }

  tags = {
    Name = "rt_nat_1"
  }
}

resource "aws_route_table" "private_rt_1" {
  vpc_id = aws_vpc.project_vpc.id

  tags = {
    Name = "rt_private_1"
  }
}

# 라우팅 테이블 연결
resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id  
}

resource "aws_route_table_association" "nat_subnet_1_association" {
  subnet_id = aws_subnet.nat_subnet_1.id
  route_table_id = aws_route_table.nat_rt_1.id  
}

resource "aws_route_table_association" "nat_subnet_2_association" {
  subnet_id = aws_subnet.nat_subnet_2.id
  route_table_id = aws_route_table.nat_rt_1.id  
}

resource "aws_route_table_association" "private_subnet_1_association" {
  subnet_id = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt_1.id  
}