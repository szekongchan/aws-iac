provider "aws" {
  region = "ap-southeast-1"
}

# Get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Get a subnet from the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Get latest Amazon Linux 2023 AMI
data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# Create SSH key pair
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh" {
  key_name   = "${var.project_name}-keypair"
  public_key = tls_private_key.ssh.public_key_openssh
}

# Save private key locally
resource "local_file" "private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = pathexpand("~/.ssh/${var.project_name}-key.pem")
  file_permission = "0400"
}

# Security group in default VPC
resource "aws_security_group" "node" {
  name        = "${var.project_name}-sg-"
  description = "setup access for SSH, prometheus scraping and HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Node Exporter"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
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
    Name = "${var.project_name}-sg"
  }
}

# EC2 instance
resource "aws_instance" "ec2node" {
  ami                         = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.node.id]
  key_name                    = aws_key_pair.ssh.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
  #!/bin/bash
  # Redirect all output to a custom log file
  exec > >(tee /var/log/user-data.log)
  exec 2>&1
  
  set -e  # Exit on error
  set -x  # Print commands as they execute
  
  echo "Starting user data script at $(date)"
  
  # Install dependencies
  echo "Installing dependencies..."
  dnf update -y
  dnf install -y git python3-pip httpd
  pip3 install gunicorn flask
  
  # Clone and setup Flask app
  echo "Setting up Flask app..."
  cd /opt
  git clone https://github.com/szekongchan/sample-flask-app.git flask-app
  cd flask-app
  
  # Set ownership to ec2-user
  chown -R ec2-user:ec2-user /opt/flask-app
  
  # Create systemd service file for Flask
  echo "Creating Flask systemd service..."
  cat > /etc/systemd/system/flask-app.service <<'SERVICE'
[Unit]
Description=Flask Application with Gunicorn
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/flask-app
Environment="PATH=/usr/local/bin:/usr/bin:/bin"
ExecStart=/usr/local/bin/gunicorn --bind 127.0.0.1:8080 --workers 3 app:app
Restart=always

[Install]
WantedBy=multi-user.target
SERVICE
  
  # Start Flask app
  systemctl daemon-reload
  systemctl enable flask-app
  systemctl start flask-app
  
  # Wait and verify Flask started
  sleep 2
  systemctl status flask-app --no-pager || echo "Flask app failed to start"
  
  # Configure Apache proxy
  echo "Configuring Apache proxy..."
  cat > /etc/httpd/conf.d/flask_proxy.conf <<'PROXY'
<VirtualHost *:80>
    ProxyPreserveHost On
    ProxyPass / http://127.0.0.1:8080/
    ProxyPassReverse / http://127.0.0.1:8080/
    
    ErrorLog /var/log/httpd/flask-error.log
    CustomLog /var/log/httpd/flask-access.log combined
</VirtualHost>
PROXY
  
  # Start Apache
  systemctl enable httpd
  systemctl start httpd
  
  # Download and install node_exporter
  echo "Downloading node_exporter..."
  cd /tmp
  wget https://github.com/prometheus/node_exporter/releases/download/v1.10.2/node_exporter-1.10.2.linux-amd64.tar.gz
  tar xzf node_exporter-1.10.2.linux-amd64.tar.gz
  rm -rf node_exporter-1.10.2.linux-amd64.tar.gz
  mv node_exporter-1.10.2.linux-amd64 /etc/node_exporter
  
  # Create node_exporter user
  useradd -rs /bin/false node_exporter
  chown -R node_exporter:node_exporter /etc/node_exporter
  
  # Create systemd service file for node_exporter
  echo "Creating node_exporter systemd service..."
  cat > /etc/systemd/system/node_exporter.service <<'SERVICE'
[Unit]
Description=Node Exporter
After=network.target

[Service]
Type=simple
User=node_exporter
ExecStart=/etc/node_exporter/node_exporter
Restart=on-failure

[Install]
WantedBy=multi-user.target
SERVICE
  
  # Start node_exporter service
  echo "Starting node_exporter service..."
  systemctl daemon-reload
  systemctl enable node_exporter
  systemctl start node_exporter
  
  # Verify services
  echo "User data script completed at $(date)"
  echo "=== Flask App Status ==="
  systemctl status flask-app --no-pager || true
  echo "=== Apache Status ==="
  systemctl status httpd --no-pager || true
  echo "=== Node Exporter Status ==="
  systemctl status node_exporter --no-pager || true
  EOF

  tags = {
    Name = "${var.project_name}-ec2"
  }
}
