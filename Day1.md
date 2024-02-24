# Script for Starting Apache Web Server

This script has to be run in Amazon Linux 2023

```
sudo su
yum update -y && yum install -y httpd
systemctl enable httpd
systemctl start httpd
curl localhost
```

To update the content served by Web Server,

```
cd /var/www/html
echo "Hello from Learn AWS in 30 days: $(hostname -i)" > index.html
curl localhost
```
