#!/bin/bash
yum update -y
amazon-linux-extras enable php8.0
yum clean metadata
yum install -y php php-mysqlnd httpd mariadb wget unzip

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Download WordPress
wget https://wordpress.org/latest.zip
unzip latest.zip
cp -r wordpress/* /var/www/html/
chown -R apache:apache /var/www/html/
chmod -R 755 /var/www/html/

# Configure wp-config.php
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

sed -i "s/database_name_here/${db_name}/" /var/www/html/wp-config.php
sed -i "s/username_here/${db_user}/" /var/www/html/wp-config.php
sed -i "s/password_here/${db_password}/" /var/www/html/wp-config.php
sed -i "s/localhost/${db_endpoint}/" /var/www/html/wp-config.php

systemctl restart httpd
