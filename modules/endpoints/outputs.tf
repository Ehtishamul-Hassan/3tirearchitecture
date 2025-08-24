output "selected_subnet_ids_one_per_az" {
  description = "Subnets actually used for Interface endpoints (one per AZ)"
  value       = local.one_per_az
}

output "interface_endpoint_ids" {
  description = "Map of interface endpoint service => endpoint ID"
  value       = { for k, v in aws_vpc_endpoint.iface : k => v.id }
}

output "gateway_endpoint_ids" {
  description = "Map of gateway endpoint service => endpoint ID"
  value       = { for k, v in aws_vpc_endpoint.gw : k => v.id }
}
