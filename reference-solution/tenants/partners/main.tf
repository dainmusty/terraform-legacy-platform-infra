# Fixes technical-debt-register item #2: the legacy version of this
# tenant had no VPC of its own at all — it hardcoded retail's VPC and
# subnet IDs as local values. That's gone. partners now has its own
# VPC via the same shared module every other tenant uses, with no
# cross-tenant reference of any kind.

module "vpc" {
  source              = "../../modules/vpc"
  tenant_name         = local.tenant_name
  vpc_cidr            = "10.2.0.0/16"
  public_subnet_cidrs = ["10.2.1.0/24", "10.2.2.0/24"]
  azs                 = ["${var.aws_region}a", "${var.aws_region}b"]
  admin_access_cidrs  = var.admin_access_cidrs
  tags                = local.common_tags
}

module "s3" {
  source      = "../../modules/s3"
  tenant_name = local.tenant_name
  tags        = local.common_tags
}

module "iam" {
  source      = "../../modules/iam"
  tenant_name = local.tenant_name
  bucket_arn  = module.s3.bucket_arn
  tags        = local.common_tags
}
