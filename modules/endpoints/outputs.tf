# Output all Interface endpoint IDs
output "interface_endpoint_ids" {
  description = "The IDs of the created Interface VPC Endpoints"
  value       = { for k, v in aws_vpc_endpoint.iface : k => v.id }
}

# Output Interface endpoint DNS names
output "interface_endpoint_dns" {
  description = "DNS names for the Interface endpoints"
  value       = { for k, v in aws_vpc_endpoint.iface : k => v.dns_entry }
}

# Output all Gateway endpoint IDs
output "gateway_endpoint_ids" {
  description = "The IDs of the created Gateway VPC Endpoints"
  value       = { for k, v in aws_vpc_endpoint.gw : k => v.id }
}

# Output Gateway endpoint service names
output "gateway_endpoint_services" {
  description = "The service names used for the Gateway endpoints"
  value       = { for k, v in aws_vpc_endpoint.gw : k => v.service_name }
}
