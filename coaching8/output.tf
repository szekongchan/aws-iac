output "dynamodb_table_name" {
  value = try(aws_dynamodb_table.bookinventory[0].name, null)
}

output "public_ip" {
  description = "Public IPv4 addresses assigned to the EC2 instances"
  value       = aws_instance.public[*].public_ip
}

output "fqdn" {
  description = "Fully Qualified Domain Names (FQDN) assigned to the EC2 instances"
  value       = aws_instance.public[*].public_dns
}
