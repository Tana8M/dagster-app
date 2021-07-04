########################################
// ------------ TAGGING ------------- //
########################################

variable "infra_env" {
  type        = string
  description = "infrastructure environment."
}

variable "infra_role" {
  type        = string
  description = "infrastructure purpose"
}


################################################
// ------------ CLUSTER PROFILE ------------- //
################################################

variable "ecs_dagster_cluster" {
  type        = string
  description = "name of the ecs cluster running dagster."
}

variable "dagit_container_port" {
  type        = string
  description = "DAGIT container port."
  default     = "3000"
}

variable "cpu" {
  type = number
  description = "Amount of cpu allocated to task."
}

variable "memory" {
  type = number
  description = "Amount of memory allocated to task."
}

variable "key_name" {
  type        = string
  description = "key pair name to ssh."
}

################################################
// ------------ CLOUDWATCH LOGS ------------- //
################################################

variable "aws_cloudwatch_log_group" {
  type        = string
  description = "name of cloudwatch group for dagster tasks."
}

##################################################
// ------------ AUTOSCALING GROUP ------------- //
##################################################

variable "launch_template_instance_type" {
  type        = string
  description = "instance type of the associated ecs optimised ami."
}

variable "protect_from_scale_in" {
  type        = bool
  description = "protects instances being terminated during scale in."
}

variable "managed_termination_protection" {
  type        = string
  description = "Enables or disables container-aware termination of instances in the auto scaling group when scale-in happens."
}

variable "target_capacity" {
  type        = number
  description = "capacity limit (%) when autoscaling scale out of instances occur due to server demand."
}

############################################
// -------------- POSTGRES -------------- //
############################################

variable "rds_instance_type" {
  type        = string
  description = "rds instance type."
}

variable "rds_allocated_storage" {
  type        = number
  description = "amount of allocated storage for rds instance (GB)."
}

variable "rds_max_allocated_storage" {
  type        = number
  description = "maximum amount allocated storage can scale for rds instance (GB). Must be larger than allocated storage."
}

variable "rds_engine_version" {
  type        = string
  description = "version of postgresql."
}

variable "rds_db_name" {
  type        = string
  description = "name of default database for rds instance."
}

variable "rds_username" {
  type        = string
  description = "usernamed for rds instance."
}

variable "skip_final_snapshot" {
  type        = bool
  description = "determines if final snapshot is created before db is deleted. Change to false in prod."
}