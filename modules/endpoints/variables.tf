variable "vpc_id" {
  description = "The ID of the VPC where the endpoints will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for interface endpoints"
  type        = list(string)
}

variable "private_route_table_ids" {
  description = "List of private route table IDs for gateway endpoints"
  type        = list(string)
}

variable "interface_endpoints" {
  description = "List of AWS services (short names) to create Interface endpoints (e.g., ssm, ec2, logs)"
  type        = list(string)
}

variable "gateway_endpoints" {
  description = "List of AWS services (short names) to create Gateway endpoints (e.g., s3, dynamodb)"
  type        = list(string)
}

variable "endpoint_sg_id" {
  description = "Security Group ID for interface endpoints"
  type        = string
}
