output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}

output "route_table_id" {
  value = aws_route_table.public.id
}

output "security_group_id" {
  value = aws_security_group.web.id
}

output "ec2_public_ip" {
  value = aws_instance.web.public_ip
}

output "ec2_instance_id" {
  value = aws_instance.web.id
}
output "lambda_function_name" {
  value = aws_lambda_function.cpennymac.function_name
}

output "eventbridge_rule" {
  value = aws_cloudwatch_event_rule.lambda_schedule.name
}
output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat.id
}
output "public_instance_ids" {
  value = aws_instance.public_ec2[*].id
}

output "public_instance_ips" {
  value = aws_instance.public_ec2[*].public_ip
}

output "private_instance_ids" {
  value = aws_instance.private_ec2[*].id
}