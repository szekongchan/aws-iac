variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "sk-coaching8"
}

# variable "vpc_name" {
#   description = "VPC Name tag used by modules"
#   type        = string
# }

variable "ec2_instance_type" {
  description = "EC2 instance type for all servers"
  type        = string
  default     = "t2.micro"
}

variable "rds_instance_type" {
  description = "RDS instance type for all servers"
  type        = string
  default     = "db.t3.micro"
}

variable "enable_dynamodb" {
  description = "Set to true to create DynamoDB resources"
  type        = bool
  default     = false
}

variable "enable_rds" {
  description = "Set to true to create RDS resources"
  type        = bool
  default     = true
}

variable "ec2_role_policy_option" {
  description = "Policy option to attach to the EC2 role: option1, option2, or option3"
  type        = string
  default     = "option1"

  validation {
    condition     = contains(["option1", "option2", "option3"], var.ec2_role_policy_option)
    error_message = "ec2_role_policy_option must be one of: option1, option2, option3."
  }
}

variable "dynamodb_items" {
  description = "Seed items to insert into DynamoDB table"
  type = list(object({
    ISBN   = string
    Genre  = string
    Title  = string
    Author = string
    Stock  = number
  }))

  default = [
    {
      ISBN   = "978-0134685991"
      Genre  = "Technology"
      Title  = "Effective Java"
      Author = "Joshua Bloch"
      Stock  = 1
    },
    {
      ISBN   = "978-0134685009"
      Genre  = "Technology"
      Title  = "Learning Python"
      Author = "Mark Lutz"
      Stock  = 2
    },
    {
      ISBN   = "974-0134789698"
      Genre  = "Fiction"
      Title  = "The Hitchhiker"
      Author = "Douglas Adams"
      Stock  = 10
    }
  ]
}
