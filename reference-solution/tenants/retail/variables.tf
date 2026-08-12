variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

variable "admin_access_cidrs" {
  description = "CIDRs allowed SSH access. Replaces the legacy 0.0.0.0/0 admin security group entirely — debt item #3."
  type        = list(string)
  default     = []
}

locals {
  tenant_name = "retail"

  # Standard tag set applied to every resource in every tenant —
  # debt item #8 (no tagging standard, cost allocation impossible).
  common_tags = {
    Tenant     = local.tenant_name
    Owner      = "retail-platform-team"
    ManagedBy  = "terraform"
    CostCentre = "CC-RETAIL-001"
  }
}
