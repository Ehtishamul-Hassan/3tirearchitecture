variable "project" {
  type        = string
  description = "Name of the project, used for tagging and naming resources"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where resources will be created"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs for EC2 or ALB placement"
}

variable "allowed_ingress_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks allowed to access this instance (e.g., for SSH/HTTP)"
  default     = ["0.0.0.0/0"] # You might want to restrict this later
}

variable "ami_id" {
  type        = string
  description = "AMI ID to use for the EC2 instance"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type (e.g., t3.micro, t3.medium)"
  default     = "t3.micro"
}

variable "key_name" {
  type        = string
  description = "SSH key pair name to attach to the instance (set null to disable)"
  default     = null
}
