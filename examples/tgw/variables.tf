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

variable "tgw_name" {
  description = "Transit gateway name"
  type        = string
  default     = "my-tgw"
}

variable "tgw_amazon_side_asn" {
  description = "Transit gateway ASN"
  type        = number
  default     = 64512
}

variable "vpc_terraform_remote_state_organization" {
  description = "Terraform Cloud organization name to read VPC data"
  type        = string
  default     = "opsta"
}

variable "vpc_terraform_remote_state_workspace" {
  description = "Terraform Cloud workspace name to read VPC data"
  type        = string
  default     = "vpc"
}
