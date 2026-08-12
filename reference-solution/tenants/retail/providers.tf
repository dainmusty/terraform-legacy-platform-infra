terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60" # same pinned major/minor across all three tenants now — debt item #5
    }
  }
  #backend "s3" {} # partial — see backend.hcl.example; per-tenant state, debt item #1
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = local.common_tags
  }
}
