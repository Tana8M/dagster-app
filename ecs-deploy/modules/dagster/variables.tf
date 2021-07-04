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

variable "subnet_private_ids" {
  type        = list(string)
  description = "List of private subnet ids."
}

variable "sg_ecs_tasks" {
  type        = string
  description = "aws security group id assigned to ecs tasks."
}

################################################
// ------------ CLUSTER PROFILE ------------- //
################################################


variable "ecs_dagster_cluster" {
  type        = string
  description = "name of the ecs cluster running dagster."
  default     = "dagster_ecs"
}

variable "dagit_container_port" {
  type        = string
  description = "port exposing dagit ui."
  default     = "3000"
}

variable "key_name" {
  type        = string
  description = "key pair name to ssh."
}

variable "cpu" {
  type = number
  description = "Amount of cpu allocated to task."
}

variable "memory" {
  type = number
  description = "Amount of memory allocated to task."
}

##################################################
// ------------ AUTOSCALING GROUP ------------- //
##################################################

variable "launch_template_instance_type" {
  type        = string
  description = "instance type of the associated ecs optimised ami."
  default     = "t2.micro"
}

variable "protect_from_scale_in" {
  type        = bool
  description = "protects instances being terminated during scale in."
  default     = false
}

variable "managed_termination_protection" {
  type        = string
  description = "Enables or disables container-aware termination of instances in the auto scaling group when scale-in happens."
  default     = "DISABLED"
}

variable "target_capacity" {
  type        = number
  description = "capacity limit (%) when autoscaling scale out of instances occur due to server demand."
  default     = 90
}

#####################################################
// ------------ EXTERNAL CREDENTIALS ------------- //
#####################################################

variable "aws_db_hostname" {
  type        = string
  description = "rds instance address."
}

variable "aws_db_password" {
  type        = string
  description = "rds password."
}


##############################################
// ------------ LOAD BALANCER ------------- //
##############################################

variable "lb_target_group_arn" {
  type        = string
  description = "load balancer target group arn."
}

variable "alb_arn" {
  type        = string
  description = "application load balancer arn"
}


################################################
// ------------ CLOUDWATCH LOGS ------------- //
################################################

variable "aws_cloudwatch_log_group" {
  type        = string
  description = "name of cloudwatch group for dagster tasks."
  default     = "awslogs-dagster"
}