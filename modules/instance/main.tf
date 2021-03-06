# ---------------------------------------------------------------------------------------------------------------------
# CREATE INSTANCE(S) ON AWS
# ---------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# This module has been updated with 0.12 syntax, which means it is no longer compatible with any versions below 0.12.
# ----------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.12"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE EC2 INSTANCE(S)
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_instance" "instance" {
  count                  = var.aws_use_spot_instance ? 0 : 1
  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.ubuntu.id
  instance_type          = var.aws_instance_type
  subnet_id              = var.aws_subnet_id
  private_ip             = var.private_ip
  vpc_security_group_ids = [aws_security_group.security_group.id]
  key_name               = var.ssh_key_name
  tags                   = { Name = var.instance_name }
  # There is no way we can do custom volume tags for each EBS right now
  # https://github.com/terraform-providers/terraform-provider-aws/issues/2891
  volume_tags            = { Name = var.instance_name }

  user_data           = templatefile("${path.module}/templates/user-data.sh", {
    ebs_block_devices = var.ebs_block_devices
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
      device_name           = ebs_block_device.value["device_name"]
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", null)
      encrypted             = lookup(ebs_block_device.value, "encrypted", null)
      iops                  = lookup(ebs_block_device.value, "iops", null)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
      volume_size           = lookup(ebs_block_device.value, "volume_size", null)
      volume_type           = lookup(ebs_block_device.value, "volume_type", null)
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE EC2 SPOT INSTANCE(S)
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_spot_instance_request" "instance" {
  count                           = var.aws_use_spot_instance ? 1 : 0
  wait_for_fulfillment            = true
  instance_interruption_behaviour = "stop"
  ami                             = var.ami_id != "" ? var.ami_id : data.aws_ami.ubuntu.id
  subnet_id                       = var.aws_subnet_id
  private_ip                      = var.private_ip
  instance_type                   = var.aws_instance_type
  vpc_security_group_ids          = [aws_security_group.security_group.id]
  key_name                        = var.ssh_key_name
  tags                            = { Name = var.instance_name }
  # There is no way we can do custom volume tags for each EBS right now
  # https://github.com/terraform-providers/terraform-provider-aws/issues/2891
  volume_tags                     = { Name = var.instance_name }

  user_data           = templatefile("${path.module}/templates/user-data.sh", {
    ebs_block_devices = var.ebs_block_devices
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
      device_name           = ebs_block_device.value["device_name"]
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", null)
      encrypted             = lookup(ebs_block_device.value, "encrypted", null)
      iops                  = lookup(ebs_block_device.value, "iops", null)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
      volume_size           = lookup(ebs_block_device.value, "volume_size", null)
      volume_type           = lookup(ebs_block_device.value, "volume_type", null)
    }
  }

  # Tag name won't apply on Spot Instance
  # https://github.com/hashicorp/terraform/issues/3263
  provisioner "local-exec" {
    command = join("", formatlist("aws ec2 create-tags --resources ${self.spot_instance_id} --tags Key=\"%s\",Value=\"%s\" --region=${var.aws_region}; ", keys(self.tags), values(self.tags)))
  }
  # Tag volume
  provisioner "local-exec" {
    command = "for eachVolume in `aws ec2 describe-volumes --region ${var.aws_region} --filters Name=attachment.instance-id,Values=${self.spot_instance_id} | jq -r .Volumes[].VolumeId`; do ${join("", formatlist("aws ec2 create-tags --resources $eachVolume --tags Key=\"%s\",Value=\"%s\" --region=${var.aws_region}; ", keys(self.tags), values(self.tags)))} done;"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE EC2 KEY PAIR
# ---------------------------------------------------------------------------------------------------------------------

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  create_key_pair = var.ssh_key_name != "" && var.ssh_public_key != "" ? true : false
  key_name        = var.ssh_key_name
  public_key      = var.ssh_public_key
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP TO CONTROL WHAT REQUESTS CAN GO IN AND OUT OF EACH EC2 INSTANCE
# We export the ID of the security group as an output variable so users can attach custom rules.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "security_group" {
  name        = var.instance_name
  description = "Security group for the ${var.instance_name} instance"
  vpc_id      = var.aws_vpc_id

  dynamic "egress" {
    for_each          = var.sg_egress_ports
    content {
      protocol        = egress.value["protocol"]
      from_port       = egress.value["from_port"]
      to_port         = egress.value["to_port"]
      cidr_blocks     = lookup(egress.value, "cidr_blocks", null)
      security_groups = lookup(egress.value, "security_groups", null)
    }
  }

  dynamic "ingress" {
    for_each          = var.sg_ingress_ports
    content {
      protocol        = ingress.value["protocol"]
      from_port       = ingress.value["from_port"]
      to_port         = ingress.value["to_port"]
      cidr_blocks     = lookup(ingress.value, "cidr_blocks", null)
      security_groups = lookup(ingress.value, "security_groups", null)
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# GET LATEST AMI ID FOR EACH OS
# ---------------------------------------------------------------------------------------------------------------------

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "centos" {
  owners      = ["679593333241"]
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ANSIBLE INVENTORY
# This will automatically create Ansible Inventory in ./inventories/*.ini directory to use with Ansible to orchetrate
# build the system
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "ansible_inventory" {
  template         = "${file("${path.module}/templates/ansible_inventory.ini")}"
  vars = {
    instance_group = var.instance_name
    instance_host  = "${var.instance_name}-server ansible_user=${var.ami_ssh_user} ansible_host=${var.aws_use_spot_instance ? aws_spot_instance_request.instance[0].public_ip : aws_instance.instance[0].public_ip} ansible_port=${var.ami_ssh_port}"
  }
}

resource "local_file" "ansible_inventory_file" {
  content  = data.template_file.ansible_inventory.rendered
  filename = "${var.ansible_inventory_path}/${var.instance_name}.ini"
}
