resource "aws_instance" "ec2_nat" {
  associate_public_ip_address = var.associate_public_ip_address
  ami                         = var.ami
  subnet_id                   = var.instance_subnet_id_nat
  instance_type               = var.instance_type
  root_block_device {
    volume_size           = var.instance_ebs_size
    volume_type           = var.ebs_type # 예: "gp2" 또는 "gp3"
    delete_on_termination = true
  }

  vpc_security_group_ids = var.sg_ec2_ids
  key_name               = var.key_name

  iam_instance_profile = var.iam_instance_profile
  tags = {
    Name = "project_ec2_${var.env}"
  }

  user_data = <<EOF
#!/bin/bash
yum update -y
yum install -y java-17-amazon-corretto-devel
sleep 10
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user
sleep 10
yum install ruby wget -y
cd /home/ec2-user
wget https://aws-codedeploy-ap-northeast-2.s3.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
EOF
}
