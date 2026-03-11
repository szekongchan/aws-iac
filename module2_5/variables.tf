variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "The name of the project, used for naming resources"
  type        = string
  default     = "sk_module2_6"
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
