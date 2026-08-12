# reference-solution/modules/vpc
#
# One VPC module, used identically by every tenant. This is the
# direct fix for technical-debt-register item #9 (copy-pasted,
# drifted per-tenant networking code) — a bug fixed here is fixed for
# every tenant, not just the one someone happened to be looking at.

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, { Name = "${var.tenant_name}-vpc" })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${var.tenant_name}-igw" })
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, { Name = "${var.tenant_name}-public-${count.index + 1}" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = merge(var.tags, { Name = "${var.tenant_name}-public-rt" })
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Admin access security group — REPLACES the old 0.0.0.0/0-on-22/3389
# pattern from the legacy retail tenant. Access is restricted to a
# variable-supplied CIDR list (your office/VPN range), never the
# whole internet, and is entirely absent unless a tenant actually
# declares admin_access_cidrs.
resource "aws_security_group" "admin_access" {
  count       = length(var.admin_access_cidrs) > 0 ? 1 : 0
  name_prefix = "${var.tenant_name}-admin-"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "SSH from approved ranges only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.admin_access_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.tenant_name}-admin-sg" })
}
