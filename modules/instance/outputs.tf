output "instance_name" {
  description = "Instance Name"
  value       = var.instance_name
}

output "public_ip" {
  description = "Instance Public IP"
  value       = aws_instance.instance.public_ip
}

output "private_ip" {
  description = "Instance Private IP"
  value       = aws_instance.instance.private_ip
}

output "ssh_port" {
  description = "Instance SSH Port"
  value       = var.ami_ssh_port
}

output "ssh_username" {
  description = "Instance SSH Username"
  value       = var.ami_ssh_user
}

output "aws_ami_ubuntu" {
  description = "AMI ID for Ubuntu 18.04"
  value       = data.aws_ami.ubuntu.id
}

output "aws_ami_centos" {
  description = "AMI ID for CentOS 7"
  value       = data.aws_ami.centos.id
}

output "aws_ami_amazon_linux" {
  description = "AMI ID for Amazon Linux"
  value       = data.aws_ami.amazon_linux.id
}
