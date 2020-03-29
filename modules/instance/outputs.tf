output "instance_name" {
  value = var.instance_name
}

output "public_ip" {
  value = aws_instance.instance.public_ip
}

output "private_ip" {
  value = aws_instance.instance.private_ip
}

output "ssh_port" {
  value = var.ami_ssh_port
}

output "ssh_username" {
  value = var.ami_ssh_user
}
