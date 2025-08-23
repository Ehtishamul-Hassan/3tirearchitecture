output "vpc_id"               { value = module.vpc.vpc_id }
output "public_alb_dns"       { value = module.nginx_proxy.alb_dns_name }
output "frontend_alb_dns"     { value = module.alb_public.alb_dns_name }
output "internal_alb_dns"     { value = module.alb_internal.alb_dns_name }
output "cloudfront_domain"    { value = module.cloudfront.domain_name }
output "rds_endpoint"         { value = module.rds.endpoint }
