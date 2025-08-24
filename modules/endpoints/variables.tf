variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Candidate private subnet IDs across AZs; module will auto-pick 1 per AZ"
  type        = list(string)
}

# Backward-compatible: you can pass either endpoint_sg_id (preferred) or sg_id
variable "endpoint_sg_id" {
  description = "Security Group ID for Interface endpoints"
  type        = string
  default     = null
}

variable "sg_id" {
  description = "Deprecated: use endpoint_sg_id instead"
  type        = string
  default     = null
}

variable "region" {
  description = "AWS Region; if null, detected automatically"
  type        = string
  default     = null
}

variable "interface_endpoints" {
  description = "List of interface endpoint service short names"
  type        = list(string)
  default = [
    "ssm",
    "ssmmessages",
    "ec2messages",
    "logs",
    "secretsmanager",
    "ecr.api",
    "ecr.dkr",
    "sts"
  ]
}

variable "gateway_endpoints" {
  description = "Gateway endpoints to create"
  type        = list(string)
  default     = ["s3", "dynamodb"]
}

variable "private_route_table_ids" {
  description = "(Optional) Private route table IDs to associate with Gateway endpoints"
  type        = list(string)
  default     = []
}
