#!/bin/bash

# Prompt user for DB connection details
echo "Enter RDS DB name:"
read db_name
echo "Enter RDS DB user:"
read db_user
echo "Enter RDS DB password:"
read db_password
echo "Enter RDS DB endpoint (no port, just the hostname):"
read db_endpoint

# Update and install packages
yum update -y
amazon-linux-extras enable php8.0
yum clean metadata
yum install -y php php-mysqlnd httpd wget unzip

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Download and install WordPress
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

# Optional: Fetch and insert secret keys
echo "Injecting WordPress salts..."
curl -s https://api.wordpress.org/secret-key/1.1/salt/ >> /tmp/wp-salts.php
# Clean old keys and insert new ones
sed -i '/AUTH_KEY/d;/SECURE_AUTH_KEY/d;/LOGGED_IN_KEY/d;/NONCE_KEY/d;/AUTH_SALT/d;/SECURE_AUTH_SALT/d;/LOGGED_IN_SALT/d;/NONCE_SALT/d' /var/www/html/wp-config.php
sed -i "/^define( 'DB_COLLATE'/r /tmp/wp-salts.php" /var/www/html/wp-config.php
rm -f /tmp/wp-salts.php

# Restart Apache
systemctl restart httpd

# Show public IP (in case it's needed for browser access)
echo "Your EC2 Public IP is:"
curl http://checkip.amazonaws.com
