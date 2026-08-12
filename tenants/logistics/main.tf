# tenants/logistics/main.tf
#
# Onboarded ~6 years ago, by a different support partner than retail.
# Clearly started as a copy-paste of retail's config, then diverged —
# different tagging style, different provider version, and a
# still-broad-but-differently-broad security group. Whoever copied
# this either didn't know about retail's IGW/route-table pattern or
# didn't trust it enough to reuse it, and rebuilt it slightly
# differently instead.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.67.0" # pinned — but to a different major version than the account's other tenants
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    environment = "logistics-prod"
    team        = "logistics-platform"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.1.1.0/24"
  tags = {
    environment = "logistics-prod"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "assoc_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.rt.id
}

# Slightly different mistake than retail's: instead of 0.0.0.0/0 on
# admin ports, this one opens the application port itself to the
# world "so the support partner's monitoring tool can reach it" —
# nobody has confirmed whether that tool still exists.
resource "aws_security_group" "app_sg" {
  name   = "logistics-app-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 8080
    to_port     = 8080
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

resource "aws_s3_bucket" "logistics_bucket" {
  bucket = "wandaprep-logistics-bucket-prod"
}

resource "aws_iam_role" "logistics_role" {
  name = "logistics-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "logistics_shared_policy" {
  role       = aws_iam_role.logistics_role.name
  policy_arn = "arn:aws:iam::111122223333:policy/wandaprep-shared-platform-access"
}
