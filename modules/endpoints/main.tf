# Gateway endpoints
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = []
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = []
}

# Interface endpoints (attach to private subnets)
resource "aws_vpc_endpoint" "iface" {
  for_each            = toset(var.interface_endpoints)
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [var.private_subnets[0], var.private_subnets[1]] # one per AZ only
  security_group_ids  = [aws_security_group.endpoint_sg.id]
}


data "aws_region" "current" {}
