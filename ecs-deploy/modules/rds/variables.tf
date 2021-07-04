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
  description = "vpc id"
}

variable "subnet_public_ids" {
  type        = list(string)
  description = "List of public subnets avaialble on vpc."
}

variable "sg_rds" {
  type        = string
  description = "aws security group of rds instance."
}


############################################
// ------------ RDS PROFILE ------------- //
############################################

variable "rds_instance_type" {
  type        = string
  description = "rds instance type."
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  type        = number
  description = "amount of allocated storage for rds instance (GB)."
  default     = 10
}

variable "rds_max_allocated_storage" {
  type        = number
  description = "maximum amount allocated storage can scale for rds instance (GB). Must be larger than allocated storage."
  default     = 30
}

variable "rds_engine_version" {
  type        = string
  description = "version of postgresql."
  default     = "13.1"
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
  default     = true
}
