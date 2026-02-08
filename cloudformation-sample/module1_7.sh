# setup in  web server
sudo dnf update -y
sudo dnf install httpd git python3-pip -y

git clone https://github.com/szekongchan/pace-coaching2.git

cd pace-coaching2
python3 -m venv .venv
source .venv/bin/activate
pip install flask

sudo vim /etc/httpd/conf.d/flask_proxy.conf

<VirtualHost *:80>
    ProxyPreserveHost On
    ProxyPass / http://127.0.0.1:8080/
    ProxyPassReverse / http://127.0.0.1:8080/
</VirtualHost>


# run server in web server
sudo systemctl start httpd
python app.py
python3 -m http.server 3000


# setup in source server
sudo dnf install telnet -y

telnet 172.31.39.103 3000
GET / HTTP/1.1
Host: ec2-47-129-253-44.ap-southeast-1.compute.amazonaws.com

# get private ip address
ec2-metadata --local-ipv4

OR 

TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4



aws ec2 run-instances \
  --image-id ami-0d70546e43a941d70 \
  --instance-type t3.micro \
  --count 1 \
  --subnet-id subnet-xxxxx \
  --security-group-ids sg-xxxxx \
  --key-name my-key-pair \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=s3-test}]'
