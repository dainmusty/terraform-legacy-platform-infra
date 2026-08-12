module "vpc" {
  source              = "../../modules/vpc"
  tenant_name         = local.tenant_name
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
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
