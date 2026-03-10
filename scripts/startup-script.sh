#!/bin/bash

apt update
apt install -y apache2

cat <<EOF > /var/www/html/index.html
<h1>Scalable Web Server Running on Google Cloud</h1>
<p>Deployed using Terraform</p>
EOF

systemctl restart apache2
