######################################
// ------- NETWORK CONFIGS -------- //
######################################

locals {
  // Overwrite this section as required.
  region = "eu-west-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket = "terraform-dagster-tutorial"
    key    = "dev-dagster"
    region = local.region
  }
}

########################################
// ------- NETWORK RESOURCES -------- //
########################################


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.1.0"
  # insert the 18 required variables here
}
