####################################
// ------------ VPC ------------- //
####################################

variable "vpc_id" {
  type        = string
  description = "vpc id."
}

variable "subnet_public_ids" {
  type        = list(string)
  description = "List of public subnet ids."
}

variable "sg_alb" {
  type        = string
  description = "ALB security group id."
}

################################################
// ------------ CLUSTER PROFILE ------------- //
################################################

variable "ecs_dagster_cluster" {
  type        = string
  description = "name of the running ecs cluster."
}

variable "dagit_container_port" {
  type        = string
  description = "port exposing dagit ui."
  default     = "3000"
}

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