locals {
  selected_subnet_ids = var.public_subnet ? data.aws_subnets.public.ids : data.aws_subnets.private.ids
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
