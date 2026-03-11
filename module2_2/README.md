# Hello World of HCL.

## Backend: Hosting terraform.tfstate file in a remote repository to faciliate collabrations

Note: variable, data and local cannot be use within terraform blocks

Reference: [provider.tf](provider.tf)

```
terraform {
  backend "tfstate-repo" {
    # The name of the S3 bucket (must already exist)
    bucket = "sctp-ce12-tfstate-bucket"
    # The path and filename for the state file within the bucket
    key    = "sk-module2_2.tfstate"
    # The AWS region of the bucket
    region = "ap-southeast-1"
  }
}
```

## S3 Resource

Reference: [main.tf](main.tf)

```
resource "aws_s3_bucket" "bucket1" {
  bucket        = "sk-module2.2-s3"
  force_destroy = true
}

```
