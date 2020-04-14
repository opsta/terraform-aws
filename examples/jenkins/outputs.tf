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
