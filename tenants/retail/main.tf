# tenants/retail/main.tf
#
# Oldest of the three tenants — onboarded ~10 years ago by the original
# platform team, before Wandaprep's current Terraform conventions
# existed. Nobody has revisited this since.

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # no version constraint — whatever's cached locally on
      # whoever's laptop last ran this
    }
  }
  # no backend block at all — state lives wherever the last engineer's
  # laptop happened to run `terraform apply` from. There is no
  # locking, no history, and no shared source of truth.
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_vpc" "retail_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "retail-vpc"
  }
}

resource "aws_subnet" "retail_public_1" {
  vpc_id     = aws_vpc.retail_vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "retail-public-1"
  }
}

resource "aws_internet_gateway" "retail_igw" {
  vpc_id = aws_vpc.retail_vpc.id
}

resource "aws_route_table" "retail_public_rt" {
  vpc_id = aws_vpc.retail_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.retail_igw.id
  }
}

resource "aws_route_table_association" "retail_public_assoc" {
  subnet_id      = aws_subnet.retail_public_1.id
  route_table_id = aws_route_table.retail_public_rt.id
}

# Admin/management security group — added years ago for "temporary"
# remote access during an incident and never narrowed afterward.
resource "aws_security_group" "retail_admin_sg" {
  name   = "retail-admin-access"
  vpc_id = aws_vpc.retail_vpc.id

  ingress {
    description = "SSH from anywhere (TEMP - narrow this later)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "RDP from anywhere (TEMP - narrow this later)"
    from_port   = 3389
    to_port     = 3389
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

resource "aws_s3_bucket" "retail_data" {
  bucket = "wandaprep-retail-data-bucket"
  # no versioning, no encryption configuration, no public access
  # block resource at all — relies entirely on the bucket's
  # account-level default, which nobody has verified in years
}

resource "aws_iam_role" "retail_app_role" {
  name = "retail_app_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Attaches the same broad, shared policy every tenant uses —
# see ../../shared/iam-broad-role.tf
resource "aws_iam_role_policy_attachment" "retail_shared_policy" {
  role       = aws_iam_role.retail_app_role.name
  policy_arn = "arn:aws:iam::111122223333:policy/wandaprep-shared-platform-access"
}
