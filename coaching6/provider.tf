terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.31.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.5.0"
    }
  }
  
  backend "s3" {
    # The name of the S3 bucket (must already exist)
    bucket = "sctp-ce12-tfstate-bucket"
    # The path and filename for the state file within the bucket
    key = "sk-coaching6.tfstate"
    # The AWS region of the bucket
    region = "ap-southeast-1"
  }
}

provider "aws" {
  region = var.aws_region
}