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

# Install Grafana
cat > /etc/yum.repos.d/grafana.repo << 'GRAFANAREPO'
[grafana]
name=grafana
baseurl=https://packages.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
GRAFANAREPO

dnf install -y grafana

# Provision Prometheus data source
mkdir -p /etc/grafana/provisioning/datasources
cat > /etc/grafana/provisioning/datasources/prometheus.yaml << 'GRAFANADS'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://localhost:9090
    isDefault: true
GRAFANADS

systemctl enable grafana-server
systemctl start grafana-server

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

# Install and configure Prometheus
echo "Setting up Prometheus..."
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v2.48.0/prometheus-2.48.0.linux-amd64.tar.gz
tar xzf prometheus-2.48.0.linux-amd64.tar.gz
rm -rf /opt/prometheus
mv prometheus-2.48.0.linux-amd64 /opt/prometheus

useradd -rs /bin/false prometheus || true
chown -R prometheus:prometheus /opt/prometheus

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
ExecStart=/opt/prometheus/prometheus --config.file=/opt/prometheus/prometheus.yml --storage.tsdb.path=/opt/prometheus/data --web.listen-address=0.0.0.0:9090
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
systemctl status grafana-server --no-pager || true