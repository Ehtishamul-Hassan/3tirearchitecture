project = "demo-3tier"
region  = "ap-south-1"

vpc_cidr = "10.0.0.0/16"
azs = ["ap-south-1a","ap-south-1b"]

public_subnet_cidrs   = ["10.0.0.0/24","10.0.1.0/24"]
frontend_subnet_cidrs = ["10.0.10.0/24","10.0.11.0/24"]
backend_subnet_cidrs  = ["10.0.20.0/24","10.0.21.0/24"]
db_subnet_cidrs       = ["10.0.30.0/24","10.0.31.0/24"]

nginx_ami_id = "ami-xxxxxxxx"      # Update
frontend_ami_id = "ami-xxxxxxxx"   # Update
backend_ami_id  = "ami-xxxxxxxx"   # Update

db_password = "ChangeMe123!"
