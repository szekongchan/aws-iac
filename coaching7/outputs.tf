output "public_ip" {
  value = module.web_app.public_ip
}

output "web_app_url" {
  value = "http://${aws_lb.default.dns_name}${module.web_app.listener_path}"
}
