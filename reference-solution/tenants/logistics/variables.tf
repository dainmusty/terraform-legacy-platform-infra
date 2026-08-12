variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

variable "admin_access_cidrs" {
  type    = list(string)
  default = []
}

locals {
  tenant_name = "logistics"

  common_tags = {
    Tenant     = local.tenant_name
    Owner      = "logistics-platform-team"
    ManagedBy  = "terraform"
    CostCentre = "CC-LOGISTICS-002"
  }
}
