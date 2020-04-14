# ---------------------------------------------------------------------------------------------------------------------
# CREATE AWS VPC
# ---------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# This module has been updated with 0.12 syntax, which means it is no longer compatible with any versions below 0.12.
# ----------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.12"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AWS VPC
# ---------------------------------------------------------------------------------------------------------------------

module "aws_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.0"

  name = var.vpc_name

  cidr            = var.vpc_cidr
  azs             = var.vpc_azs
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_ipv6 = false

  enable_nat_gateway = true
  enable_vpn_gateway = true

  private_subnet_tags = var.custom_private_subnet_tags
  public_subnet_tags  = var.custom_public_subnet_tags
}
