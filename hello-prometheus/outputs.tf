output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.ec2node.public_ip
}

output "private_key_path" {
  description = "Path to the private key file"
  value       = local_file.private_key.filename
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ~/.ssh/${var.project_name}-key.pem ec2-user@${aws_instance.ec2node.public_ip}"
}

output "flask_app_url" {
  description = "Flask Application URL"
  value       = "http://${aws_instance.ec2node.public_ip}"
}

output "grafana_url" {
  description = "Grafana URL"
  value       = "http://${aws_instance.ec2node.public_ip}:3000"
}
