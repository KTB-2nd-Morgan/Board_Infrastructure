output "vpc_id" {
  value = aws_vpc.project_vpc.id
}

output "subnet_public_1" {
  value = aws_subnet.public_subnet_1
}

output "subnet_nat_1" {
  value = aws_subnet.nat_subnet_1
}

output "subnet_private_1" {
  value = aws_subnet.private_subnet_1
}

output "nat_ip" {
  value = aws_eip.nat_eip_azone.public_ip
}

output "nat_gateway_id" {
  value = aws_nat_gateway.project_nat_azone.id
}

output "rt_nat_1_id" {
  value = aws_route_table.nat_rt_1.id
}