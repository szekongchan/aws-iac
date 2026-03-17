resource "aws_instance" "private_ec2" {
  ami           = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type = var.ec2_instance_type
  subnet_id     = flatten(module.vpc.private_subnets)[0]
  #  subnet_id              = data.aws_subnets.private.ids[0]
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.profile_ec2.name

  user_data = <<-EOF
    #!/bin/bash
    sudo dnf install mariadb105 -y
  EOF

  tags = {
    Name = "${var.project_name}-ec2"
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-ec2-sg"
  description = "EC2 Security Group for ${var.project_name}"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.ec2_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# for testing of s3 ls and ec2 describe
resource "aws_vpc_security_group_egress_rule" "allow_https_ipv4" {
  security_group_id = aws_security_group.ec2_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_sql_ipv4" {
  count                        = var.enable_rds ? 1 : 0
  security_group_id            = aws_security_group.ec2_sg.id
  referenced_security_group_id = aws_security_group.db_sg[0].id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
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

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.6.0"

  name                               = "${var.project_name}-vpc"
  cidr                               = "172.31.0.0/16"
  azs                                = data.aws_availability_zones.available.names
  public_subnets                     = ["172.31.101.0/24", "172.31.102.0/24"]
  private_subnets                    = ["172.31.1.0/24", "172.31.2.0/24"]
  database_subnets                   = ["172.31.201.0/24", "172.31.202.0/24"]
  create_database_subnet_route_table = true
  enable_nat_gateway                 = true
  single_nat_gateway                 = true
}
