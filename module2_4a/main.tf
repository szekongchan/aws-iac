module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~>6.6.0"

  name = "${var.project_name}-vpc"
  cidr = var.cidr_block

  azs             = data.aws_availability_zones.available.names
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  public_subnets  = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]

  enable_nat_gateway   = false
  single_nat_gateway   = false
  enable_dns_hostnames = true

  tags = {
    Terraform = "true"
  }
}
