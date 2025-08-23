# Gateway endpoints
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = []
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = []
}

# Interface endpoints (attach to private subnets)
resource "aws_vpc_endpoint" "iface" {
  for_each = toset([
    "ecr.api","ecr.dkr","logs","sts","secretsmanager","ssm","ec2messages","ssmmessages"
  ])
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.${each.key}"
  vpc_endpoint_type = "Interface"
  subnet_ids        = var.subnets
  security_group_ids = [var.sg_id]
  private_dns_enabled = true
}

data "aws_region" "current" {}
