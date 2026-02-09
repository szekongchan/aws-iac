# Simple demo for Prometheus / Garfana in AWS. Challenge Task of NTU PACE Coaching 1.2 Session

## Setup of EC2 with flask app and node exporter

1. Flask App with gunicorn on port 8080
2. HTTPD as proxy for Flask App on port 80
3. Node Exporter on port 9100

## Troubleshooting Tips for Node Exporters Installation

### Check if user data ran

```
# View the full output
sudo cat /var/log/cloud-init-output.log

# Check for errors
sudo grep -i error /var/log/cloud-init-output.log

# Check if node_exporter is running
sudo systemctl status node_exporter

# Check if the service file was created
ls -la /etc/systemd/system/node_exporter.service
```

### Then check your custom log:

```
sudo cat /var/log/user-data.log
```

### Quick Troubleshooting Commands

```
# Is node_exporter running?
sudo systemctl status node_exporter

# View service logs
sudo journalctl -u node_exporter -n 50

# Check if binary exists
ls -la /etc/node_exporter/

# Test node_exporter manually
sudo /etc/node_exporter/node_exporter --version
```

## AWS Manged Promethues Resource

### 1. **IAM Resources for AMP Access**

- **IAM Role** (`aws_iam_role.ec2_amp_role`): Allows EC2 to assume a role
- **IAM Policy** (`aws_iam_role_policy.amp_remote_write`): Grants permissions to write metrics to AMP
- **IAM Instance Profile** (`aws_iam_instance_profile.ec2_amp_profile`): Attaches the role to EC2

### 2. **Amazon Managed Prometheus Workspace**

- **`aws_prometheus_workspace.main`**: Creates the AMP workspace where metrics will be stored

### 3. **Prometheus Installation in User Data**

- Downloads and installs Prometheus on the EC2 instance
- Configures Prometheus to scrape metrics from:
  - Node Exporter (port 9100) - system metrics
  - Flask app (port 8080) - application metrics (if your app exposes `/metrics`)
- Configures **remote_write** to send metrics to AMP using SigV4 authentication

### 4. **Outputs**

- AMP workspace ID, endpoint, and remote write URL
- EC2 public IP and Flask app URL

### How it works:

```
EC2 Instance
├── Node Exporter (port 9100) ──┐
├── Flask App (port 8080) ───────┤
│ │
└── Prometheus ──────────────────┴──> scrapes metrics
│
└──> remote_write (with SigV4 auth)
│
▼
Amazon Managed Prometheus (AMP)
```
