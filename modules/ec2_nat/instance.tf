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
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user
sleep 10
yum install ruby wget -y
cd /home/ec2-user
wget https://aws-codedeploy-ap-northeast-2.s3.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto

yum install -y amazon-cloudwatch-agent


TIMESTAMP=$(date '+%Y-%m-%d-%H-%M-%S')
cat <<EOC > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "/morgan/backend",
            "log_stream_name": "backend-messages-$${TIMESTAMP}",
            "timestamp_format": "%b %d %H:%M:%S"
          },
          {
            "file_path": "/var/log/cloud-init.log",
            "log_group_name": "/morgan/backend",
            "log_stream_name": "backend-cloudinit-$${TIMESTAMP}"
          }
        ]
      }
    },
    "log_stream_name": "default-log-stream",
    "force_flush_interval": 15
  }
}
EOC

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -s
EOF
}
