locals {
  subnet_id = sort(data.aws_subnets.default.ids)[0]
}

resource "aws_instance" "public" {
  ami                         = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type               = var.ec2_instance_type
  subnet_id                   = local.subnet_id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.keypair.key_name
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.profile_ec2.name

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
  vpc_id      = data.aws_vpc.default.id
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
