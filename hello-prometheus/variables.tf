variable "project_name" {
  description = "Project name"
  type        = string
  default     = "sk-hello-prometheus"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "ap-southeast-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}
