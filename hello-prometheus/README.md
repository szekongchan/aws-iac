# Simple demo for Prometheus / Garfana in AWS. Challenge Task of NTU PACE Coaching 1.2 Session

## Setup

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
