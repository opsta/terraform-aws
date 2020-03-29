# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A SINGLE NODE GITLAB
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  backend "remote" {
    organization = "opsta"

    workspaces {
      name = "gitlab"
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
# DEPLOY A SINGLE GITLAB EC2 INSTANCE
# ---------------------------------------------------------------------------------------------------------------------

module "gitlab" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "github.com/opsta/terraform-aws.git//modules/gitlab?ref=master"
  source = "../../modules/instance"

  instance_name          = var.instance_name
  ssh_key_name           = var.ssh_key_name
  ssh_public_key         = var.ssh_public_key
  aws_instance_type      = var.aws_instance_type
  root_volume_size       = var.root_volume_size
  ebs_block_devices      = var.ebs_block_devices
  ebs_volume_device_name = var.ebs_volume_device_name
  ebs_volume_mount_point = var.ebs_volume_mount_point
}
