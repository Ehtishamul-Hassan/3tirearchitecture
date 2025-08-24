variable "vpc_id" { type = string }
variable "subnets" { type = list(string) }
variable "sg_id" { type = string }

variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "interface_endpoints" {
  description = "List of AWS interface endpoints to create (services)"
  type        = list(string)
  default = [
    "ssm",
    "ssmmessages",
    "ec2messages"
  ]
}
