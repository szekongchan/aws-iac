module "web_app" {
  source = "./modules/web_app"

  name_prefix    = var.name_prefix
  instance_type  = var.instance_type
  instance_count = var.instance_count
  vpc_id         = module.vpc.vpc_id
  public_subnet  = var.public_subnet
}

# Supposed to be using a shared environment, to use this VPC until shared environment is ready.
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~>6.6.0"

  name = "${var.name_prefix}-vpc"
  cidr = var.vpc_cidr_block

  azs             = [data.aws_availability_zones.available.names[0]]
  private_subnets = [var.private_cidr_block]
  public_subnets  = [var.public_cidr_block]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform = "true"
  }
}
