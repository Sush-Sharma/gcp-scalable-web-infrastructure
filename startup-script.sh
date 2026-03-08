#!/bin/bash
apt update
apt install apache2 -y
systemctl start apache2
systemctl enable apache2

echo "<h1>Scalable Web Server</h1>" > /var/www/html/index.html
echo "<p>Instance: $(hostname)</p>" >> /var/www/html/index.html
