output "public_ip" {
  description = "Public IPv4 addresses assigned to the EC2 instances"
  value       = aws_instance.public[*].public_ip
}
