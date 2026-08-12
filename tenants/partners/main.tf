# tenants/partners/main.tf
#
# The newest tenant (~2 years old), built by a support partner who
# was told to "just point it at what retail already has" to save
# time. As a result this tenant isn't really independent at all — it
# hardcodes retail's VPC ID and reuses retail's IAM role directly,
# rather than having its own. Nobody has documented this coupling
# anywhere outside this comment.

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

# Hardcoded — this is meant to be retail's VPC ID, copied out of the
# AWS console by hand at the time this was written. If retail's VPC is
# ever recreated (e.g. during the remediation this exercise asks you
# to do), this silently points at nothing, or worse, at whatever
# resource happens to get that ID next.
locals {
  retail_vpc_id    = "vpc-0123456789abcdef0"
  retail_subnet_id = "subnet-0123456789abcdef0"
}

resource "aws_security_group" "partners_sg" {
  name   = "partners-access"
  vpc_id = local.retail_vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_s3_bucket" "partners_bucket" {
  bucket = "wandaprep-partners-data"
}

resource "aws_instance" "partners_app" {
  ami                    = "ami-0abcdef1234567890"
  instance_type          = "t3.medium"
  subnet_id              = local.retail_subnet_id
  vpc_security_group_ids = [aws_security_group.partners_sg.id]

  # No IAM role of its own — reuses retail's role and, by extension,
  # retail's assume-role trust policy and the shared broad policy
  # attached to it. A change to retail's IAM role changes what
  # partners' EC2 instance can do, with nobody who owns partners aware
  # that's true.
  iam_instance_profile = "retail_app_role"

  tags = {
    Name = "partners-app-instance"
  }
}
