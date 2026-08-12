variable "tenant_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "azs" {
  type = list(string)
}

variable "admin_access_cidrs" {
  description = "CIDRs allowed admin (SSH) access. Leave empty to skip creating an admin security group entirely."
  type        = list(string)
  default     = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
