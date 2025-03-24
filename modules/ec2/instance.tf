resource "aws_instance" "ec2" {
  associate_public_ip_address = var.associate_public_ip_address
  ami = var.ami
  subnet_id = var.instance_subnet_id
  instance_type = var.instance_type
  vpc_security_group_ids = var.sg_ec2_ids
  key_name = var.key_name  
    tags = {
        Name = "project_ec2_${var.env}"
    }
}

resource "aws_instance" "ec2_opnevpn" {
  associate_public_ip_address = true
  ami = var.openvpn_ami
  subnet_id = var.instance_subnet_id
  instance_type = var.instance_type
  vpc_security_group_ids = var.sg_ec2_ids
  key_name = var.key_name  
    tags = {
        Name = "project_ec2_openvpn_${var.env}"
    }
}