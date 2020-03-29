# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
# ---------------------------------------------------------------------------------------------------------------------

# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY

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
  default     = "nexus"
}

variable "ssh_key_name" {
  description = "The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances. Set to an empty string to not associate a Key Pair."
  type        = string
  default     = "opsta"
}

variable "aws_instance_type" {
  description = "AWS instance type"
  type        = string
  default     = "t3a.medium"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "root_volume_size" {
  description = "The size, in GB, of the root EBS volume."
  type        = number
  default     = 40
}

variable "ebs_block_devices" {
  description = "A list of EBS volumes to attach to each EC2 Instance. Each item in the list should be an object with the keys 'device_name', 'volume_type', 'volume_size', 'iops', 'delete_on_termination', and 'encrypted', as defined here: https://www.terraform.io/docs/providers/aws/r/launch_configuration.html#block-devices. Also there is 'path' key to use with user data shell script to mount path automatically."
  # We can't narrow the type down more than "any" because if we use list(object(...)), then all the fields in the
  # object will be required (whereas some, such as encrypted, should be optional), and if we use list(map(...)), all
  # the values in the map must be of the same type, whereas we need some to be strings, some to be bools, and some to
  # be ints. So, we have to fall back to just any ugly "any."
  type    = any
  # default = []
  default = [
    {
      device_name           = "/dev/xvdh"
      volume_type           = "gp2"
      volume_size           = 100
      delete_on_termination = false
      path                  = "/opt"
    }
  ]
}

# variable "ssh_public_key" {
#   description = "Public Key to create EC2 Key Pair that can be used to SSH to the EC2 Instances. Set to an empty string to not create Key Pair."
#   type        = string
#   default     = "CHANGEME"
# }
