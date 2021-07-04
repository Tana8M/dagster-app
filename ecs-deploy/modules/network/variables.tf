########################################
// ------------ TAGGING ------------- //
########################################

variable "infra_env" {
  type        = string
  description = "infrastructure environment."
  default     = "staging"
}

variable "infra_role" {
  type        = string
  description = "infrastructure purpose"
  default     = "dagster"
}


########################################
// ------------ NETWORK ------------- //
########################################

variable "vpc_cidr_block" {
  type        = string
  description = "cidr block for vpc"
}

variable "private_subnets" {
  type        = list(string)
  description = "list of cidr_blocks for private subnets."
  default     = []
}

variable "public_subnets" {
  type        = list(string)
  description = "list of cidr_blocks for public subnets."
  default     = []
}

variable "availability_zones" {
  type        = list(string)
  description = "list of availability zones in region."
  default     = []
}

variable "ingress_cidr_block" {
  type = list(string)
  description = "list of inbound cidr_blocks. In production set this to IP address of your vpn."
  default = ["0.0.0.0/0"]
}


############################################
// ------------ ECS CLUSTER ------------- //
############################################

variable "dagit_container_port" {
  type        = string
  description = "DAGIT container port."
  default     = "3000"
}
