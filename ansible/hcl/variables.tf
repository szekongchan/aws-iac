variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "The name of the project, used for naming resources"
  type        = string
  default     = "sk_ansible"
}

variable "instance_count" {
  description = "The number of EC2 instances to create"
  type        = number
  default     = 2
}

variable "instance_type" {
  description = "The type of EC2 instance to create"
  type        = string
  default     = "t3.micro"
}
