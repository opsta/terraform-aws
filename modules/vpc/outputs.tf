output "vpc_id" {
  description = "VPC ID"
  value       = module.aws_vpc.vpc_id
}

output "private_subnets" {
  description = "List of Private Subnets ID"
  value       = module.aws_vpc.private_subnets
}

output "public_subnets" {
  description = "List of Public Subnets ID"
  value       = module.aws_vpc.public_subnets
}
