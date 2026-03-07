locals {
  selected_subnet_ids = var.public_subnet ? var.public_subnet_ids : var.private_subnet_ids
}

resource "aws_instance" "web_app" {
  count                  = var.instance_count
  ami                    = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type          = var.instance_type
  subnet_id              = local.selected_subnet_ids[count.index % length(local.selected_subnet_ids)]
  vpc_security_group_ids = [aws_security_group.web_app.id]
  user_data = templatefile("${path.module}/init-script.sh", {
    file_content = "webapp-#${count.index}"
  })

  associate_public_ip_address = var.public_subnet
  tags = {
    Name = "${var.name_prefix}-webapp-${count.index}"
  }
}

resource "aws_security_group" "web_app" {
  name        = "${var.name_prefix}-webapp-sg"
  description = "Allow traffic to webapp"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.name_prefix}-webapp-sg"
  }
}

resource "aws_lb_target_group" "web_app" {
  name     = "${var.name_prefix}-webapp-targetgrp"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.selected.id

  health_check {
    port     = 80
    protocol = "HTTP"
    timeout  = 3
    interval = 5
  }
}

resource "aws_lb_target_group_attachment" "web_app" {
  count            = var.instance_count
  target_group_arn = aws_lb_target_group.web_app.arn
  target_id        = aws_instance.web_app[count.index].id
  port             = 80
}

resource "aws_lb_listener_rule" "web_app" {
  listener_arn = var.lb_listener_arn
  count        = var.lb_listener_arn != "" ? 1 : 0
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_app.arn
  }
  condition {
    path_pattern {
      values = ["/${var.lb_listener_path_pattern}"]
    }
  }
}
