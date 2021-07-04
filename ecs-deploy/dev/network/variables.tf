###############################
// ----------- TAGS -------- //
###############################

variable "infra_env" {
  type        = string
  description = "resource environment."
}

##################################
// ----------- NETWORK -------- //
##################################

variable "vpc_cidr_block" {
  type        = string
  description = "cidr block for vpc."
}

variable "private_subnets" {
  type        = list(string)
  description = "list of cidr_blocks for private subnets."
}

variable "public_subnets" {
  type        = list(string)
  description = "list of cidr_blocks for public subnets."
}

variable "availability_zones" {
  type        = list(string)
  description = "list of availability zones in region."
}

variable "dagit_container_port" {
  type        = string
  description = "container port for dagit ui, associated to dagster.."
  default     = "3000"
}

variable "ingress_cidr_block" {
  type = list(string)
  description = "list of inbound cidr_blocks. In production set this to IP address of your vpn."
}