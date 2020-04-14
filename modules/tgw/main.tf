# ---------------------------------------------------------------------------------------------------------------------
# CREATE AWS TRANSIT GATEWAY
# ---------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# This module has been updated with 0.12 syntax, which means it is no longer compatible with any versions below 0.12.
# ----------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.12"
}

# ------------------------------------------------------------------------------
# READ VPC DATA FROM TERRAFROM CLOUD REMOTE STATE
# ------------------------------------------------------------------------------

data "terraform_remote_state" "vpc" {

  backend = "remote"

  config = {
    organization = var.vpc_terraform_remote_state_organization
    workspaces = {
      name = var.vpc_terraform_remote_state_workspace
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AWS TRANSIT GATEWAY
# ---------------------------------------------------------------------------------------------------------------------

module "tgw" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "~> 1.0"

  name                                  = var.tgw_name
  amazon_side_asn                       = var.tgw_amazon_side_asn
  enable_auto_accept_shared_attachments = true

  vpc_attachments  = {
    tm_demo_vpc    = {
      vpc_id                                          = data.terraform_remote_state.vpc.outputs.vpc_id
      subnet_ids                                      = data.terraform_remote_state.vpc.outputs.private_subnets
      dns_support                                     = true
      ipv6_support                                    = false
      transit_gateway_default_route_table_association = true
      transit_gateway_default_route_table_propagation = true
    }
  }
}
