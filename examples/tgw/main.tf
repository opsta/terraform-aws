# ---------------------------------------------------------------------------------------------------------------------
# CREATE AWS TRANSIT GATEWAY
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  backend "remote" {
    organization = "opsta"

    workspaces {
      name = "tgw"
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
# CREATE AWS TRANSIT GATEWAY
# ---------------------------------------------------------------------------------------------------------------------

module "tm_vpc_tgw" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "github.com/opsta/terraform-aws.git//modules/tgw?ref=master"
  source = "../../modules/tgw"

  tgw_name                                = var.tgw_name
  tgw_amazon_side_asn                     = var.tgw_amazon_side_asn
  vpc_terraform_remote_state_organization = var.vpc_terraform_remote_state_organization
  vpc_terraform_remote_state_workspace    = var.vpc_terraform_remote_state_workspace
}
