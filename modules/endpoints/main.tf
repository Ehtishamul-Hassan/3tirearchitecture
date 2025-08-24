data "aws_region" "current" {}

locals {
  region_resolved = coalesce(var.region, data.aws_region.current.name)
  endpoint_sg_id  = coalesce(var.endpoint_sg_id, var.sg_id)
}

# Look up AZ for each provided subnet
data "aws_subnet" "selected" {
  for_each = toset(var.subnet_ids)
  id       = each.value
}

# Build list of unique AZs and pick exactly one subnet per AZ
locals {
  azs = distinct([for s in values(data.aws_subnet.selected) : s.availability_zone])

  # map AZ -> [subnet ids in that AZ]
  subnets_by_az = {
    for az in local.azs :
    az => [for s in values(data.aws_subnet.selected) : s.id if s.availability_zone == az]
  }

  # choose the first subnet from each AZ bucket (one per AZ)
  one_per_az = [for az in local.azs : local.subnets_by_az[az][0]]
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
  for_each        = toset(contains(var.gateway_endpoints, "s3") ? var.private_route_table_ids : [])
  vpc_endpoint_id = aws_vpc_endpoint.gw["s3"].id
  route_table_id  = each.value
}

resource "aws_vpc_endpoint_route_table_association" "dynamodb_assoc" {
  for_each        = toset(contains(var.gateway_endpoints, "dynamodb") ? var.private_route_table_ids : [])
  vpc_endpoint_id = aws_vpc_endpoint.gw["dynamodb"].id
  route_table_id  = each.value
}
