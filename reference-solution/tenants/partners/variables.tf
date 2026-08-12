variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

variable "admin_access_cidrs" {
  type    = list(string)
  default = []
}

locals {
  tenant_name = "partners"

  common_tags = {
    Tenant     = local.tenant_name
    Owner      = "partners-platform-team"
    ManagedBy  = "terraform"
    CostCentre = "CC-PARTNERS-003"
  }
}
