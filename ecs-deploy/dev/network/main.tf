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
      Name        = "data-network"
      ManagedBy   = "terraform"
      Environment = "staging"
    }
  }
}

#############################
// ------- NETWORK-------- //
#############################


module "network" {
  source = "../../modules/network"
  // TAGS
  infra_env = var.infra_env
  // NETWORK
  vpc_cidr_block     = var.vpc_cidr_block
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
  availability_zones = var.availability_zones
  // CLUSTER
  dagit_container_port = var.dagit_container_port
}