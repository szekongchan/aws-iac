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

# IAM role for EC2 to write to AMP
resource "aws_iam_role" "ec2_amp_role" {
  name = "${var.project_name}-ec2-amp-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-ec2-amp-role"
  }
}

# IAM policy for AMP remote write
resource "aws_iam_role_policy" "amp_remote_write" {
  name = "${var.project_name}-amp-remote-write-policy"
  role = aws_iam_role.ec2_amp_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "aps:RemoteWrite",
          "aps:QueryMetrics",
          "aps:GetSeries",
          "aps:GetLabels",
          "aps:GetMetricMetadata"
        ]
        Resource = aws_prometheus_workspace.main.arn
      }
    ]
  })
}

# Attach SSM policy for EC2 instance management (optional but useful)
resource "aws_iam_role_policy_attachment" "ssm_managed_instance" {
  role       = aws_iam_role.ec2_amp_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# IAM instance profile
resource "aws_iam_instance_profile" "ec2_amp_profile" {
  name = "${var.project_name}-ec2-amp-profile"
  role = aws_iam_role.ec2_amp_role.name

  tags = {
    Name = "${var.project_name}-ec2-amp-profile"
  }
}

# Amazon Managed Service for Prometheus Workspace
resource "aws_prometheus_workspace" "main" {
  alias = "${var.project_name}-workspace"

  tags = {
    Name = "${var.project_name}-amp-workspace"
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
  iam_instance_profile        = aws_iam_instance_profile.ec2_amp_profile.name

  user_data = <<EOF
#!/bin/bash
exec > >(tee /var/log/user-data.log)
exec 2>&1

set -x

echo "Starting user data script at $(date)"

# Install dependencies
dnf update -y
dnf install -y git python3-pip httpd
pip3 install gunicorn flask

# Clone and setup Flask app
cd /opt
git clone https://github.com/szekongchan/sample-flask-app.git flask-app
cd flask-app
chown -R ec2-user:ec2-user /opt/flask-app

# Create Flask systemd service
cat > /etc/systemd/system/flask-app.service << 'FLASKSERVICE'
[Unit]
Description=Flask Application with Gunicorn
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/flask-app
Environment="PATH=/usr/local/bin:/usr/bin:/bin"
ExecStart=/usr/bin/python3 -m gunicorn --bind 127.0.0.1:8080 --workers 3 app:app
Restart=always

[Install]
WantedBy=multi-user.target
FLASKSERVICE

systemctl daemon-reload
systemctl enable flask-app
systemctl start flask-app
sleep 5

# Configure SELinux for Apache proxy
setsebool -P httpd_can_network_connect 1 || true

# Configure Apache proxy
cat > /etc/httpd/conf.d/flask_proxy.conf << 'APACHEPROXY'
<VirtualHost *:80>
    ProxyPreserveHost On
    ProxyPass / http://127.0.0.1:8080/
    ProxyPassReverse / http://127.0.0.1:8080/
    
    ErrorLog /var/log/httpd/flask-error.log
    CustomLog /var/log/httpd/flask-access.log combined
</VirtualHost>
APACHEPROXY

systemctl enable httpd
systemctl start httpd

# Download and install node_exporter
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.10.2/node_exporter-1.10.2.linux-amd64.tar.gz
tar xzf node_exporter-1.10.2.linux-amd64.tar.gz
rm -rf /etc/node_exporter
mv node_exporter-1.10.2.linux-amd64 /etc/node_exporter

useradd -rs /bin/false node_exporter || true
chown -R node_exporter:node_exporter /etc/node_exporter

cat > /etc/systemd/system/node_exporter.service << 'NODESERVICE'
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
NODESERVICE

systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter

# Install and configure Prometheus for AMP remote write
echo "Setting up Prometheus for AMP remote write..."
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v2.48.0/prometheus-2.48.0.linux-amd64.tar.gz
tar xzf prometheus-2.48.0.linux-amd64.tar.gz
rm -rf /opt/prometheus
mv prometheus-2.48.0.linux-amd64 /opt/prometheus

useradd -rs /bin/false prometheus || true
chown -R prometheus:prometheus /opt/prometheus

# Get AMP workspace endpoint
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
AMP_WORKSPACE_ID="${aws_prometheus_workspace.main.id}"
AMP_ENDPOINT="https://aps-workspaces.$REGION.amazonaws.com/workspaces/$AMP_WORKSPACE_ID/api/v1/remote_write"

# Create Prometheus configuration
cat > /opt/prometheus/prometheus.yml << PROMCONFIG
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']
        labels:
          instance: 'ec2-instance'
          
  - job_name: 'flask_app'
    static_configs:
      - targets: ['localhost:8080']
        labels:
          instance: 'flask-app'

remote_write:
  - url: $AMP_ENDPOINT
    queue_config:
      max_samples_per_send: 1000
      max_shards: 200
      capacity: 2500
    sigv4:
      region: $REGION
PROMCONFIG

chown prometheus:prometheus /opt/prometheus/prometheus.yml

# Create Prometheus systemd service
cat > /etc/systemd/system/prometheus.service << 'PROMSERVICE'
[Unit]
Description=Prometheus
After=network.target

[Service]
Type=simple
User=prometheus
ExecStart=/opt/prometheus/prometheus --config.file=/opt/prometheus/prometheus.yml --storage.tsdb.path=/opt/prometheus/data --web.listen-address=127.0.0.1:9090
Restart=on-failure

[Install]
WantedBy=multi-user.target
PROMSERVICE

systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus

echo "User data script completed at $(date)"
systemctl status flask-app --no-pager || true
systemctl status httpd --no-pager || true
systemctl status node_exporter --no-pager || true
systemctl status prometheus --no-pager || true
EOF

  tags = {
    Name = "${var.project_name}-ec2"
  }
}
