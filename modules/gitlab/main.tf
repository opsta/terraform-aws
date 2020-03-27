# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A SINGLE NODE GITLAB
# ---------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# This module has been updated with 0.12 syntax, which means it is no longer compatible with any versions below 0.12.
# ----------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.12"
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A SINGLE GITLAB EC2 INSTANCE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_instance" "gitlab" {
  ami                     = var.ami_id
  instance_type           = var.gitlab_instance_type
  vpc_security_group_ids  = [aws_security_group.gitlab_security_group.id]
  key_name                = var.ssh_key_name
  tags                    = { Name = var.instance_name }
  volume_tags             = { Name = var.instance_name }

  user_data                   = templatefile("${path.module}/templates/user-data.sh", {
    # Pass in the data about the EBS volumes so they can be mounted
    gitlab_volume_device_name = var.gitlab_volume_device_name
    gitlab_volume_mount_point = var.gitlab_volume_mount_point
  })

  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    delete_on_termination = var.root_volume_delete_on_termination
    iops                  = var.root_volume_iops
  }

  dynamic "ebs_block_device" {
    for_each                = var.ebs_block_devices
    content {
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", null)
      device_name           = ebs_block_device.value["device_name"]
      encrypted             = lookup(ebs_block_device.value, "encrypted", null)
      iops                  = lookup(ebs_block_device.value, "iops", null)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
      volume_size           = lookup(ebs_block_device.value, "volume_size", null)
      volume_type           = lookup(ebs_block_device.value, "volume_type", null)
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP TO CONTROL WHAT REQUESTS CAN GO IN AND OUT OF EACH EC2 INSTANCE
# We export the ID of the security group as an output variable so users can attach custom rules.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "gitlab_security_group" {
  name        = "gitlab-instance"
  description = "Security group for the GitLab instance"
  vpc_id      = data.aws_subnet_ids.default.vpc_id

  // Allow all egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Allow all ICMP
  ingress {
    protocol = "icmp"
    from_port = -1
    to_port = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each    = var.gitlab_ports
    content {
      from_port = ingress.value
      to_port   = ingress.value
      protocol  = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY GITLAB IN THE DEFAULT VPC AND SUBNETS
# Using the default VPC and subnets makes it easy to run and test, but it means GitLab is accessible from
# the public Internet. For a production deployment, we strongly recommend deploying into a custom VPC with private
# subnets.
# ---------------------------------------------------------------------------------------------------------------------

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

data "template_file" "ansible_inventory" {
  template       = "${file("${path.module}/templates/gitlab.ini")}"
  vars = {
    gitlab_group = var.instance_name
    gitlab_host  = "${var.instance_name}-server ansible_user=${var.ami_ssh_user} ansible_host=${aws_instance.gitlab.public_ip} ansible_port=${var.ami_ssh_port}"
  }
}

resource "local_file" "ansible_inventory_file" {
  content  = data.template_file.ansible_inventory.rendered
  filename = "./inventories/${var.instance_name}.ini"
}
