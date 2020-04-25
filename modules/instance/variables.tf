# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
# ---------------------------------------------------------------------------------------------------------------------

# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY
# AWS_PROFILE

# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = "The AWS region in which all resources will be created"
  type        = string
  default     = "ap-southeast-1"
}

variable "instance_name" {
  description = "AWS instance name"
  type        = string
}

variable "ssh_key_name" {
  description = "The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances. Set to an empty string to not associate a Key Pair."
  type        = string
  default     = ""
}

variable "ssh_public_key" {
  description = "Public Key to create EC2 Key Pair that can be used to SSH to the EC2 Instances. Set to an empty string to not create Key Pair."
  type        = string
  default     = ""
}

variable "aws_instance_type" {
  description = "AWS instance type"
  type        = string
  default     = "t3a.small"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "private_ip" {
  description = "Instance Private IP"
  type        = string
  default     = null
}

variable "aws_subnet_id" {
  description = "VPC Subnet ID to spawn instance"
  type        = string
  default     = null
}

variable "aws_use_spot_instance" {
  description = "Use AWS Spot Instance"
  type        = bool
  default     = true
}

variable "aws_vpc_id" {
  description = "The ID of the VPC. This is only use in case of you don't want to use default VPC"
  type        = string
  default     = ""
}

variable "ami_id" {
  description = "The ID of the AMI to create instance. This is only use in case of you don't want our default Ubuntu AMI"
  type        = string
  default     = ""
}

variable "ami_ssh_user" {
  description = "Username for building Ansible Inventory to SSH"
  type        = string
  default     = "ubuntu"
}

variable "ami_ssh_port" {
  description = "Username for building Ansible Inventory to SSH"
  type        = number
  default     = 22
}

variable "sg_egress_ports" {
  description = "A list of Egress Security Groups to attach to each EC2 Instance. Each item in the list should be an object with the keys 'protocol', 'from_port', 'to_port', 'cidr_blocks'."
  # We can't narrow the type down more than "any" because if we use list(object(...)), then all the fields in the
  # object will be required (whereas some, such as encrypted, should be optional), and if we use list(map(...)), all
  # the values in the map must be of the same type, whereas we need some to be strings, some to be bools, and some to
  # be ints. So, we have to fall back to just any ugly "any."
  type    = any
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "sg_ingress_ports" {
  description = "A list of Ingress Security Groups to attach to each EC2 Instance. Each item in the list should be an object with the keys 'protocol', 'from_port', 'to_port', 'cidr_blocks'."
  # We can't narrow the type down more than "any" because if we use list(object(...)), then all the fields in the
  # object will be required (whereas some, such as encrypted, should be optional), and if we use list(map(...)), all
  # the values in the map must be of the same type, whereas we need some to be strings, some to be bools, and some to
  # be ints. So, we have to fall back to just any ugly "any."
  type    = any
  default = [
    {
      protocol    = "icmp"
      from_port   = -1
      to_port     = -1
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      protocol    = "tcp"
      from_port   = 22
      to_port     = 22
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "root_volume_type" {
  description = "The type of volume. Must be one of: standard, gp2, or io1."
  default     = "gp2"
}

variable "root_volume_size" {
  description = "The size, in GB, of the root EBS volume."
  type        = number
  default     = 40
}

variable "root_volume_delete_on_termination" {
  description = "Whether the volume should be destroyed on instance termination."
  type        = bool
  default     = false
}

variable "root_volume_iops" {
  description = "The amount of provisioned IOPS for the root volume. Only used if volume type is io1."
  type        = number
  default     = 0
}

variable "ebs_block_devices" {
  description = "A list of EBS volumes to attach to each EC2 Instance. Each item in the list should be an object with the keys 'device_name', 'volume_type', 'volume_size', 'iops', 'delete_on_termination', and 'encrypted', as defined here: https://www.terraform.io/docs/providers/aws/r/launch_configuration.html#block-devices. Also there is 'path' key to use with user data shell script to mount path automatically."
  # We can't narrow the type down more than "any" because if we use list(object(...)), then all the fields in the
  # object will be required (whereas some, such as encrypted, should be optional), and if we use list(map(...)), all
  # the values in the map must be of the same type, whereas we need some to be strings, some to be bools, and some to
  # be ints. So, we have to fall back to just any ugly "any."
  type    = any
  default = []
  # default = [
  #   {
  #     device_name           = "/dev/xvdh"
  #     volume_type           = "gp2"
  #     volume_size           = 40
  #     delete_on_termination = false
  #     path                  = "var/lib/myapp"
  #   }
  # ]
}

variable "ansible_inventory_path" {
  description = "Path where Ansible Inventory is going to generate"
  type        = string
  default     = "./inventories"
}
