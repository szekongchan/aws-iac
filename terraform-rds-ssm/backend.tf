terraform {
  required_version = ">= 1.14.0"

  backend "s3" {
    bucket = "sctp-ce8-tfstate"
    key    = "jaz-rds.tfstate"
    region = "ap-southeast-1"
  }
}
