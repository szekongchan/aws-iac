# Terraform Notes

## Backend: Hosting terraform.tfstate file in a remote repository to faciliate collabrations

Note: variable, data and local cannot be use within terraform blocks

Reference: module2_2/backend.tf

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

## Retrival of ami with SSM

Reference: coaching6/

```
data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "public" {
  ami                         = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type               = var.instance_type
  subnet_id                   = local.subnet_id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ssh.key_name
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "${var.project_name}-ec2"
  }
}
```

## Key Pair Generation: Using hashicorp/tls to generate key pair and hashicorp/local to store the pem file in a local folder

Security Note: This approach exposes the private key and pem file contents on the tftstate file and also save a copy of the pem file in your local drive. Care has to be taken to protect these files from unauthorize access.

Reference: coaching6/

```
terraform {
  required_version = ">= 1.0"

  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.5.0"
    }
  }
}

# Create private key
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Generate AWS Key Pair
resource "aws_key_pair" "keypair" {
  key_name   = "${var.project_name}-keypair"
  public_key = tls_private_key.key.public_key_openssh
}

# Save private key locally
resource "local_file" "private_key" {
  content         = tls_private_key.key.private_key_pem
  filename        = pathexpand("~/.ssh/${var.project_name}-keypair.pem")
  file_permission = "0400"
}
```
