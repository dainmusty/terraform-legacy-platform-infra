output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "admin_sg_id" {
  value = length(aws_security_group.admin_access) > 0 ? aws_security_group.admin_access[0].id : null
}
