#!/bin/bash

echo "testing network at $(date)" >> /var/log/user-data.log

# Wait for internet connectivity (important for EC2 user data)
until ping -c1 8.8.8.8 &>/dev/null; do sleep 1; done

echo "update package cache at $(date)" >> /var/log/user-data.log

# Update package cache
yum update -y

echo "check if httpd is installed at $(date)" >> /var/log/user-data.log

# Check if httpd is installed using rpm (works for both yum and dnf)
if ! rpm -q httpd >/dev/null 2>&1; 
then
  echo "httpd not installed, installing" >> /var/log/user-data.log
  yum install -y httpd
else
  echo "httpd already installed." >> /var/log/user-data.log
fi

echo "starting httpd at $(date)" >> /var/log/user-data.log

# Ensure service is started and enabled
systemctl start httpd
systemctl enable httpd

# Log completion for debugging
echo "httpd setup complete at $(date)" >> /var/log/user-data.log
