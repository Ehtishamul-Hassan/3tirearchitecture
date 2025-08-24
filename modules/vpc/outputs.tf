output "vpc_id" { value = aws_vpc.this.id }
output "public_subnet_ids" { value = [for s in aws_subnet.public : s.id] }
output "frontend_subnet_ids" { value = [for s in aws_subnet.frontend : s.id] }
output "backend_subnet_ids" { value = [for s in aws_subnet.backend : s.id] }
output "db_subnet_ids" { value = [for s in aws_subnet.db : s.id] }

output "private_subnet_ids_all" {
  value = concat(
    [for s in aws_subnet.frontend : s.id],
    [for s in aws_subnet.backend : s.id],
    [for s in aws_subnet.db : s.id]
  )
}

output "endpoints_sg_id" { value = aws_security_group.endpoints.id }

# Existing outputs … plus:
output "private_route_table_ids" {
  description = "Private route tables (one per AZ)"
  value       = [for rt in aws_route_table.private : rt.id]
}

