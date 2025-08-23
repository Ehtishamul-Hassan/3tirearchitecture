variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "azs" {
  type = list(string) # e.g., ["ap-south-1a","ap-south-1b"]
}

variable "public_subnet_cidrs" {
  type = list(string) # 2
}

variable "frontend_subnet_cidrs" {
  type = list(string) # 2
}

variable "backend_subnet_cidrs" {
  type = list(string) # 2
}

variable "db_subnet_cidrs" {
  type = list(string) # 2
}

# Nginx AMI/Launch template basics
variable "nginx_ami_id" {
  type = string
}

variable "nginx_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type    = string
  default = null
}

# Application AMIs (if EC2 ASG pattern). If ECS, replace with your ECS modules.
variable "frontend_ami_id" {
  type = string
}

variable "backend_ami_id" {
  type = string
}

variable "frontend_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "backend_instance_type" {
  type    = string
  default = "t3.micro"
}

# DB
variable "db_engine" {
  type    = string
  default = "postgres"
}

variable "db_engine_version" {
  type    = string
  default = "15.5"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.medium"
}

variable "db_name" {
  type    = string
  default = "appdb"
}

variable "db_username" {
  type    = string
  default = "appuser"
}

variable "db_password" {
  type      = string
  sensitive = true
}
