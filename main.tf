locals {
  name = var.project
}

module "vpc" {
  source                = "./modules/vpc"
  project               = var.project
  vpc_cidr              = var.vpc_cidr
  azs                   = var.azs
  public_subnet_cidrs   = var.public_subnet_cidrs
  frontend_subnet_cidrs = var.frontend_subnet_cidrs
  backend_subnet_cidrs  = var.backend_subnet_cidrs
  db_subnet_cidrs       = var.db_subnet_cidrs
}

module "endpoints" {
  source = "./modules/endpoints"

  vpc_id                  = module.vpc.vpc_id
  private_subnet_ids      = module.vpc.private_subnet_ids_all
  private_route_table_ids = module.vpc.private_route_table_ids
  interface_endpoints     = ["s3", "ec2"]      # example
  gateway_endpoints       = ["s3", "dynamodb"] # example
  endpoint_sg_id          = module.vpc.endpoints_sg_id
}



# Nginx Reverse Proxy (public) behind an ALB (CloudFront origin)
module "nginx_proxy" {
  source                = "./modules/nginx_proxy"
  project               = var.project
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  allowed_ingress_cidrs = ["0.0.0.0/0"] # tighten to CloudFront ranges later
  ami_id                = var.nginx_ami_id
  instance_type         = var.nginx_instance_type
  key_name              = var.key_name
}

# Public ALB that receives traffic from Nginx and targets Frontend
module "alb_public" {
  source         = "./modules/alb_public"
  project        = var.project
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.public_subnet_ids
  allowed_sg_ids = [module.nginx_proxy.alb_sg_id] # only from Nginx ALB SG
}

# Frontend ASG (private) behind Public ALB target group
module "asg_frontend" {
  source           = "./modules/asg_frontend"
  project          = var.project
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.frontend_subnet_ids
  ami_id           = var.frontend_ami_id
  instance_type    = var.frontend_instance_type
  key_name         = var.key_name
  target_group_arn = module.alb_public.tg_arn
}

# Internal ALB between Frontend and Backend
module "alb_internal" {
  source         = "./modules/alb_internal"
  project        = var.project
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.backend_subnet_ids
  allowed_sg_ids = [module.asg_frontend.sg_id] # only from Frontend SG
}

# Backend ASG (private) behind Internal ALB
module "asg_backend" {
  source           = "./modules/asg_backend"
  project          = var.project
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.backend_subnet_ids
  ami_id           = var.backend_ami_id
  instance_type    = var.backend_instance_type
  key_name         = var.key_name
  target_group_arn = module.alb_internal.tg_arn
}

# RDS Multi-AZ
module "rds" {
  source         = "./modules/rds"
  project        = var.project
  vpc_id         = module.vpc.vpc_id
  db_subnet_ids  = module.vpc.db_subnet_ids
  sg_source_ids  = [module.asg_backend.sg_id] # only backend may access DB
  engine         = var.db_engine
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class
  db_name        = var.db_name
  username       = var.db_username
  password       = var.db_password
}



module "cloudfront" {
  source             = "./modules/cloudfront"
  project            = var.project
  origin_domain_name = module.nginx_proxy.alb_dns_name

}
