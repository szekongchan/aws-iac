variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "sk-module2_7"
}

variable "vpc_name" {
  description = "VPC Name tag used by modules"
  type        = string
  default     = "ce-learner-vpc"
}

variable "ec2_instance_type" {
  description = "EC2 instance type for all servers"
  type        = string
  default     = "t2.micro"
}
