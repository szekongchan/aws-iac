#!/bin/bash
sudo yum update -y
sudo yum install httpd -y
sudo systemctl enable httpd
sudo systemctl start httpd
# shellcheck disable=SC2154  # file_content is injected by Terraform's templatefile()
echo "${file_content}" >/var/www/html/index.html

# loads index.html on all paths
echo 'RewriteEngine On' >>/etc/httpd/conf.d/custom.conf
echo 'RewriteRule ^/[a-zA-Z0-9]+[/]?$ /index.html [QSA,L]' >>/etc/httpd/conf.d/custom.conf
systemctl restart httpd
