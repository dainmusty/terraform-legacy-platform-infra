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

  validation {
    condition = alltrue([
      for cidr in var.admin_access_cidrs :
      cidr != "0.0.0.0/0"
    ])

    error_message = "admin_access_cidrs must never contain 0.0.0.0/0. Use an approved corporate, VPN, or bastion CIDR."
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}
