variable "project_name" {
  description = "Project name"
  type        = string
  default     = "sk-hello-prometheus"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}
