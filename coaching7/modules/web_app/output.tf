output "public_ip" {
  value = aws_instance.web_app[*].public_ip
}

output "listener_path" {
  value = var.lb_listener_arn != "" ? var.lb_listener_path_pattern : ""
}
