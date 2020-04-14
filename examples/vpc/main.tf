# ---------------------------------------------------------------------------------------------------------------------
# CREATE AWS VPC
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  backend "remote" {
    organization = "opsta"

    workspaces {
      name = "vpc"
    }
  }
}

# ------------------------------------------------------------------------------
# CONFIGURE OUR AWS CONNECTION
# ------------------------------------------------------------------------------

provider "aws" {
  # The AWS region in which all resources will be created
  region = var.aws_region
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AWS VPC
# ---------------------------------------------------------------------------------------------------------------------

module "aws_vpc" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "github.com/opsta/terraform-aws.git//modules/vpc?ref=master"
  source = "../../modules/vpc"

  vpc_name            = var.vpc_name
  vpc_cidr            = var.vpc_cidr
  vpc_private_subnets = var.vpc_private_subnets
  vpc_public_subnets  = var.vpc_public_subnets
}
