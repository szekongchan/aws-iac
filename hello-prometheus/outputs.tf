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

output "amp_workspace_id" {
  description = "Amazon Managed Prometheus Workspace ID"
  value       = aws_prometheus_workspace.main.id
}

output "amp_workspace_endpoint" {
  description = "Amazon Managed Prometheus Workspace Endpoint"
  value       = aws_prometheus_workspace.main.prometheus_endpoint
}

output "amp_remote_write_url" {
  description = "AMP Remote Write URL"
  value       = "${aws_prometheus_workspace.main.prometheus_endpoint}api/v1/remote_write"
}

output "flask_app_url" {
  description = "Flask Application URL"
  value       = "http://${aws_instance.ec2node.public_ip}"
}
