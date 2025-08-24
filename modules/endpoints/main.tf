data "aws_region" "current" {}

locals {
  region_resolved = coalesce(var.region, data.aws_region.current.name)
  endpoint_sg_id  = coalesce(var.endpoint_sg_id, var.sg_id)
}

# Look up AZ for each provided subnet

data "aws_subnets" "all" {
  filter {
    name   = "subnet-id"
    values = var.subnet_ids
  }
}

data "aws_subnet" "all" {
  for_each = toset(var.subnet_ids)
  id       = each.value
}

locals {
  azs = distinct([for s in data.aws_subnet.all : s.availability_zone])

  # pick the *first* subnet in each AZ
  one_per_az = [
    for az in local.azs : (
      [for s in data.aws_subnet.all : s.id if s.availability_zone == az][0]
    )
  ]
}


#########################
# Interface Endpoints
#########################
resource "aws_vpc_endpoint" "iface" {
  for_each            = toset(var.interface_endpoints)
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${local.region_resolved}.${each.value}"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = local.one_per_az
  security_group_ids  = [local.endpoint_sg_id]

  tags = {
    Name = "iface-${each.value}"
  }
}

#########################
# Gateway Endpoints
#########################
# Create (optional) S3/DynamoDB gateway endpoints
resource "aws_vpc_endpoint" "gw" {
  for_each          = toset(var.gateway_endpoints)
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${local.region_resolved}.${each.value}"
  vpc_endpoint_type = "Gateway"
  # If you don't supply route tables here, we add them below via associations
}

# Associate gateway endpoints to private route tables (if provided)
resource "aws_vpc_endpoint_route_table_association" "s3_assoc" {
  for_each = {
    for idx, rt in var.private_route_table_ids :
    idx => rt
    if contains(var.gateway_endpoints, "s3")
  }
  vpc_endpoint_id = aws_vpc_endpoint.gw["s3"].id
  route_table_id  = each.value
}

resource "aws_vpc_endpoint_route_table_association" "dynamodb_assoc" {
  for_each = {
    for idx, rt in var.private_route_table_ids :
    idx => rt
    if contains(var.gateway_endpoints, "dynamodb")
  }
  vpc_endpoint_id = aws_vpc_endpoint.gw["dynamodb"].id
  route_table_id  = each.value
}

