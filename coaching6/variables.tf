variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Environment name"
  type        = string
  default     = "sk-coaching2"
}

variable "instance_type" {
  description = "EC2 instance type for all servers"
  type        = string
  default     = "t2.micro"
}
