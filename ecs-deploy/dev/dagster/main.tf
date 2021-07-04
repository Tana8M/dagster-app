###############################
// ------- TF CONFIG-------- //
###############################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"

  default_tags {
    tags = {
      Name        = "data-dagster"
      ManagedBy   = "terraform"
      Environment = "staging"
    }
  }
}


#####################################
// ------- NETWORK LOOKUPS-------- //
#####################################

// Security groups
data "aws_security_group" "ecs_tasks" {
  name = "dagster-sg-task-*"
}

data "aws_security_group" "alb" {
  name = "dagster-sg-alb-*"
}

data "aws_security_group" "rds" {
  name = "dagster-sg-postgres-*"
}

// Public Subnets

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["vpc-data"]
  }
}

data "aws_subnet_ids" "public" {
  // .ids attrib will return a set, apply sort() to index
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name   = "tag:Name"
    values = ["*-subnet-public-data"]
  }
}

data "aws_subnet_ids" "private" {
  // .ids attrib will return a set, apply sort() to index
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name   = "tag:Name"
    values = ["*-subnet-private-data"]
  }
}


##################################
// ------- ECS DAGSTER -------- //
##################################

module "ecs_dagster" {
  source = "../../modules/ecs-dagster"
  // TAGS
  infra_env  = var.infra_env
  infra_role = var.infra_role
  // NETWORK
  vpc_id             = data.aws_vpc.vpc.id
  subnet_public_ids  = sort(data.aws_subnet_ids.public.ids)
  subnet_private_ids = sort(data.aws_subnet_ids.private.ids)
  sg_ecs_tasks       = data.aws_security_group.ecs_tasks.id
  // CLUSTER
  ecs_dagster_cluster  = var.ecs_dagster_cluster
  dagit_container_port = var.dagit_container_port
  key_name             = var.key_name
  // CLOUDWATCH LOGS
  aws_cloudwatch_log_group = var.aws_cloudwatch_log_group
  // AUTOSCALING GROUP
  launch_template_instance_type  = var.launch_template_instance_type
  protect_from_scale_in          = var.protect_from_scale_in
  managed_termination_protection = var.managed_termination_protection
  target_capacity                = var.target_capacity
  // OTHER CREDENTIALS
  aws_db_hostname = module.rds_postgres.rds_hostname
  aws_db_password = module.rds_postgres.rds_password
  // LOAD BALANCER
  lb_target_group_arn = module.load_balancer.lb_target_group_arn
  alb_arn             = module.load_balancer.alb_arn
  // Depends on RDS 
  depends_on = [
    module.rds_postgres
  ]
}

########################################
// ------- POSTGRES INSTANCE -------- //
########################################

module "rds_postgres" {
  source = "../../modules/rds"
  // TAGS
  infra_env  = var.infra_env
  infra_role = var.infra_role
  // NETWORK
  vpc_id            = data.aws_vpc.vpc.id
  subnet_public_ids = sort(data.aws_subnet_ids.public.ids)
  sg_rds            = data.aws_security_group.rds.id
  // PROFILE
  rds_instance_type         = var.rds_instance_type
  rds_allocated_storage     = var.rds_allocated_storage
  rds_max_allocated_storage = var.rds_max_allocated_storage
  rds_engine_version        = var.rds_engine_version
  rds_db_name               = var.rds_db_name
  rds_username              = var.rds_username
  skip_final_snapshot       = var.skip_final_snapshot
}

####################################
// ------- LOAD BALANCER -------- //
####################################

module "load_balancer" {
  source = "../../modules/lb"
  // TAGS
  infra_env  = var.infra_env
  infra_role = var.infra_role
  // NETWORK
  vpc_id            = data.aws_vpc.vpc.id
  subnet_public_ids = sort(data.aws_subnet_ids.public.ids)
  sg_alb            = data.aws_security_group.alb.id
  // CLUSTER
  ecs_dagster_cluster  = var.ecs_dagster_cluster
  dagit_container_port = var.dagit_container_port
}
