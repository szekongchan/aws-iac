locals {
  az_count = 2
  azs      = slice(data.aws_availability_zones.available.names, 0, local.az_count)
}

# Supposed to be using a shared environment, to use this VPC until shared environment is ready.
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~>6.6.0"

  name = "${var.name_prefix}-vpc"
  cidr = var.vpc_cidr_block

  azs                = local.azs
  private_subnets    = var.private_cidr_blocks
  public_subnets     = var.public_cidr_blocks
  enable_nat_gateway = true
  single_nat_gateway = true
}

resource "aws_lb" "default" {
  name               = "${var.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = module.vpc.public_subnets

  tags = {
    Name = "${var.name_prefix}-alb"
  }
}

resource "aws_lb_listener" "default" {
  load_balancer_arn = aws_lb.default.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "OK"
      status_code  = "200"
    }
  }
}

resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-alb-sg"
  description = "Allow HTTP traffic to ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-alb-sg"
  }
}

module "web_app" {
  source = "./modules/web_app"

  name_prefix        = var.name_prefix
  instance_type      = var.instance_type
  instance_count     = var.instance_count
  vpc_id             = module.vpc.vpc_id
  public_subnet      = var.public_subnet
  public_subnet_ids  = module.vpc.public_subnets
  private_subnet_ids = module.vpc.private_subnets
  lb_listener_arn    = aws_lb_listener.default.arn
}
