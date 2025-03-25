locals {
  openvpn_setup_script = templatefile("${path.module}/openvpn_setup.exp.tpl", {
    openvpn_password = var.openvpn_password
  })
}

resource "aws_instance" "ec2_openvpn" {
  associate_public_ip_address = var.associate_public_ip_address
  ami                         = var.openvpn_ami
  subnet_id                   = var.instance_subnet_id_openvpn
  instance_type               = var.instance_type
  root_block_device {
    volume_size           = var.instance_ebs_size
    volume_type           = var.ebs_type
    delete_on_termination = true
  }
  vpc_security_group_ids = var.sg_ec2_ids
  key_name               = var.key_name

  user_data = <<EOF
#!/bin/bash
sleep 30
cat << EOF2 > /tmp/openvpn_setup.exp
${local.openvpn_setup_script}
EOF2
chmod +x /tmp/openvpn_setup.exp
/tmp/openvpn_setup.exp
sleep 10
sudo /usr/local/openvpn_as/scripts/sacli --user openvpn --new_pass "${var.openvpn_password}" SetLocalPassword
EOF
  # rm -f /tmp/openvpn_setup.exp
  tags = {
    Name = "project_ec2_openvpn_${var.env}"
  }
}
