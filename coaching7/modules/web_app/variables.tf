variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
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
  default     = true
}

variable "vpc_id" {
  description = "ID of the VPC where resources will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs to launch instances in"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs to launch instances in"
  type        = list(string)
}

variable "lb_listener_arn" {
  description = "ALB Listener Arn"
  type        = string
  default     = ""
}

variable "lb_listener_path_pattern" {
  description = "ALB Listener Path Pattern"
  type        = string
  default     = "/szekong*"
}
