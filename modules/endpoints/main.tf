data "aws_region" "current" {}

resource "aws_vpc_endpoint" "iface" {
  for_each            = toset(var.interface_endpoints)
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.${each.value}"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = slice(var.private_subnet_ids, 0, 2) # one per AZ
  security_group_ids  = [var.endpoint_sg_id]
}

resource "aws_vpc_endpoint" "gw" {
  for_each          = toset(var.gateway_endpoints)
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.${each.value}"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.private_route_table_ids
}
