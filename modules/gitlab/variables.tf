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

variable "ssh_key_name" {
  description = "The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Set to an empty string to not associate a Key Pair."
  type        = string
  default     = null
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "instance_name" {
  description = "GitLab instance name"
  type        = string
  default     = "gitlab"
}

# TODO Can select latest Ubuntu Server 18.04
variable "ami_id" {
  description = "The ID of the AMI to run in the cluster. This should be Ubuntu 18.04 LTS"
  type        = string
  # Ubuntu Server 18.04 LTS (HVM), SSD Volume Type (64-bit x86) in ap-southeast-1
  default     = "ami-09a4a9ce71ff3f20b"
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

variable "gitlab_instance_type" {
  description = "AWS instance type"
  type        = string
  default     = "t3a.medium"
}

variable "gitlab_ports" {
  description = "Port used by GitLab."
  type        = list(number)
  default     = ["22", "80", "443"]
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
  description = "A list of EBS volumes to attach to each EC2 Instance. Each item in the list should be an object with the keys 'device_name', 'volume_type', 'volume_size', 'iops', 'delete_on_termination', and 'encrypted', as defined here: https://www.terraform.io/docs/providers/aws/r/launch_configuration.html#block-devices. We recommend using one EBS Volume for each instance."
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
      volume_size           = 40
      delete_on_termination = false
    }
  ]
}

variable "gitlab_volume_device_name" {
  description = "The device name to use for the EBS Volume used for the data directories on GitLab node."
  type        = string
  default     = "/dev/xvdh"
}

variable "gitlab_volume_mount_point" {
  description = "The mount point (folder path) to use for the EBS Volume used for the data directories on GitLab node."
  type        = string
  default     = "/var/opt/gitlab"
}
