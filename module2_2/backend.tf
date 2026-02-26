terraform {
  backend "s3" {
    # The name of the S3 bucket (must already exist)
    bucket = "sctp-ce12-tfstate-bucket"
    # The path and filename for the state file within the bucket
    key    = "sk-module2_2.tfstate"
    # The AWS region of the bucket
    region = "ap-southeast-1"    
  }
}