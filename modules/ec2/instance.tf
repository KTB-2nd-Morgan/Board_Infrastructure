resource "aws_instance" "ec2_nat" {
  associate_public_ip_address = var.associate_public_ip_address
  ami = var.ami
  subnet_id = var.instance_subnet_id_nat
  instance_type = var.instance_type
  root_block_device {
    volume_size = var.instance_ebs_size
    volume_type = var.ebs_type           # 예: "gp2" 또는 "gp3"
    delete_on_termination = true
  }
  
  vpc_security_group_ids = var.sg_ec2_ids
  key_name = var.key_name  
    tags = {
        Name = "project_ec2_${var.env}"
    }
}

resource "aws_instance" "ec2_opnevpn" {
  associate_public_ip_address = true
  subnet_id = var.instance_subnet_id_openvpn
  instance_type = var.instance_type
  root_block_device {
    volume_size = var.instance_ebs_size
    volume_type = var.ebs_type
    delete_on_termination = true
  }
  vpc_security_group_ids = var.sg_ec2_ids
  key_name = var.key_name  
    tags = {
        Name = "project_ec2_openvpn_${var.env}"
    }
}