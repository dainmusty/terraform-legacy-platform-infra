output "vpc_id" {
  value = module.vpc.vpc_id
}

output "bucket_name" {
  value = module.s3.bucket_id
}

output "iam_role_arn" {
  value = module.iam.role_arn
}
