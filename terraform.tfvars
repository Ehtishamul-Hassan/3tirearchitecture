# ------------------------
# Global Project Settings
# ------------------------
project  = "my-app-3tire"
region   = "ap-south-1"
azs      = ["ap-south-1a", "ap-south-1b"]
vpc_cidr = "10.0.0.0/16"

# ------------------------
# Subnet CIDRs
# ------------------------
public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
frontend_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
backend_subnet_cidrs  = ["10.0.21.0/24", "10.0.22.0/24"]
db_subnet_cidrs       = ["10.0.31.0/24", "10.0.32.0/24"]

# ------------------------
# Nginx Proxy (Public)
# ------------------------
nginx_ami_id        = "ami-0c4a668b99e68bbde" # replace with latest Amazon Linux 2 AMI
nginx_instance_type = "t2.micro"
key_name            = "MumbaiKeyPair"

# ------------------------
# Frontend ASG
# ------------------------
frontend_ami_id        = "ami-0bb5c192b55aa769f" # replace with your frontend AMI
frontend_instance_type = "t2.micro"

# ------------------------
# Backend ASG
# ------------------------
backend_ami_id        = "ami-005f43d0c2026d87b" # replace with your backend AMI
backend_instance_type = "t2.micro"

# ------------------------
# RDS Database
# ------------------------
db_engine         = "mysql"
db_engine_version = "8.0.35"
db_instance_class = "db.t3.micro"
db_name           = "securelibrarymanagementsystem"
db_username       = "root"
db_password       = "12345678"
