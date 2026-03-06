variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "sk_coaching7"
}

variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "ap-southeast-1"
}

variable "instance_type" {
  description = "EC2 instance type for all servers"
  type        = string
  default     = "t2.micro"
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 2
}

variable "public_subnet" {
  description = "Whether to create resources in a public subnet"
  type        = bool
  default     = false
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.88.0.0/16"
}

variable "public_cidr_block" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.88.1.0/24"
}

variable "private_cidr_block" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.88.2.0/24"
}
