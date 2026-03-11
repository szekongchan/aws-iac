# Loop: EC2 Count Parameter + Security Group

Reference: [main.tf](main.tf)

## Count Parameter

```
resource "aws_instance" "public" {
  count                       = var.instance_count
  ami                         = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type               = var.instance_type
  subnet_id                   = local.subnet_id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.keypair.key_name
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "${var.project_name}-ec2-${count.index + 1}"
  }
}
```

## Security Group

```
resource "aws_security_group" "allow_ssh" {
  name        = "sk-public-sg"
  description = "Allow SSH inbound"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
```
