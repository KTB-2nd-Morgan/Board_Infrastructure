output "nat_instance_id" {
  value = aws_instance.ec2_nat.id
}

output "nat_instance_name" {
  value = aws_instance.ec2_nat.tags["Name"]
}
