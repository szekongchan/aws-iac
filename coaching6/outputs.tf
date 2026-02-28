output "ssh_commands" {
  description = "SSH commands to connect to instances"
  value = {
    ec2     = "ssh -i ${local_file.private_key.filename} ec2-user@${aws_instance.public.public_ip}"
  }
}
