#!/bin/sh
apt update -y
apt install -y httpd

systemctl start httpd
systemctl enable httpd

echo "<h1>suck it!</h1>" > /var/www/html/index.html
