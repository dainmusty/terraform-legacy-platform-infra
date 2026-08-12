output "role_name" {
  value = aws_iam_role.tenant.name
}

output "role_arn" {
  value = aws_iam_role.tenant.arn
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.tenant.name
}
