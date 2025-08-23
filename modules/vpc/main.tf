resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project}-igw"
  }
}

# Public subnets (2)
resource "aws_subnet" "public" {
  for_each = { for idx, cidr in var.public_subnet_cidrs : idx => cidr }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = var.azs[tonumber(each.key)]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-public-${each.key}"
  }
}

# Private: frontend, backend, db
resource "aws_subnet" "frontend" {
  for_each = { for idx, cidr in var.frontend_subnet_cidrs : idx => cidr }

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = var.azs[tonumber(each.key)]

  tags = {
    Name = "${var.project}-frontend-${each.key}"
  }
}

resource "aws_subnet" "backend" {
  for_each = { for idx, cidr in var.backend_subnet_cidrs : idx => cidr }

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = var.azs[tonumber(each.key)]

  tags = {
    Name = "${var.project}-backend-${each.key}"
  }
}

resource "aws_subnet" "db" {
  for_each = { for idx, cidr in var.db_subnet_cidrs : idx => cidr }

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = var.azs[tonumber(each.key)]

  tags = {
    Name = "${var.project}-db-${each.key}"
  }
}

# NAT per AZ
resource "aws_eip" "nat" {
  for_each = aws_subnet.public

  domain = "vpc"

  tags = {
    Name = "${var.project}-nat-eip-${each.key}"
  }
}

resource "aws_nat_gateway" "nat" {
  for_each = aws_subnet.public

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = {
    Name = "${var.project}-nat-${each.key}"
  }
}

# Route tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project}-rt-public"
  }
}

resource "aws_route" "public_inet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# One private RT per AZ that points to local NAT
resource "aws_route_table" "private" {
  for_each = aws_subnet.public

  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project}-rt-private-${each.key}"
  }
}

resource "aws_route" "private_default" {
  for_each = aws_route_table.private

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[each.key].id
}

locals {
  az_index = { for i, az in var.azs : az => i }
}

resource "aws_route_table_association" "frontend_assoc" {
  for_each = aws_subnet.frontend

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[tostring(local.az_index[each.value.availability_zone])].id
}

resource "aws_route_table_association" "backend_assoc" {
  for_each = aws_subnet.backend

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[tostring(local.az_index[each.value.availability_zone])].id
}

resource "aws_route_table_association" "db_assoc" {
  for_each = aws_subnet.db

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[tostring(local.az_index[each.value.availability_zone])].id
}

# SG for endpoints (allow from VPC)
resource "aws_security_group" "endpoints" {
  name        = "${var.project}-endpoints-sg"
  description = "Interface endpoints SG"
  vpc_id      = aws_vpc.this.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-endpoints-sg"
  }
}
