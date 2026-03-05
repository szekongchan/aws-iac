variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "The name of the project, used for naming resources"
  type        = string
  default     = "sk_module2_4"
}

variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.1.0.0/16"
}
