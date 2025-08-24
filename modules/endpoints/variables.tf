variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "private_route_table_ids" {
  type = list(string)
}

variable "interface_endpoints" {
  type = list(string)
}

variable "gateway_endpoints" {
  type = list(string)
}

variable "endpoint_sg_id" {
  type = string
}
