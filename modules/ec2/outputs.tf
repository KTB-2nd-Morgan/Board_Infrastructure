output "nat_instance_id" {
  value = aws_instance.ec2_nat.id
}

output "openvpn_instance_id" {
  value = aws_instance.ec2_opnevpn.id
}