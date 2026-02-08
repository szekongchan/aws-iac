provider "aws" {
  region = "ap-southeast-1"
}

data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "sk-vpc"
  cidr = "172.32.0.0/16"

  azs             = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  private_subnets = ["172.32.1.0/24", "172.32.2.0/24"]
  public_subnets  = ["172.32.3.0/24", "172.32.4.0/24"]

  enable_nat_gateway = true
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type = var.instance_type

  vpc_security_group_ids = [module.vpc.default_security_group_id]
  subnet_id              = module.vpc.private_subnets[0]

  tags = {
    Name = var.instance_name
  }
}
