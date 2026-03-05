variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "The name of the project, used for naming resources"
  type        = string
  default     = "sk_module2_4b"
}

variable "cart_count" {
  type    = number
  default = 1
}
