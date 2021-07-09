#!/bin/bash

echo "

*****************************************************************

	Starting Installer...

*****************************************************************
"
sleep 5

yum remove mariadb* -y
yum install -y httpd net-tools expect expect wget unzip net-tools yum-utils

# Enableing PHP 7.4 repo 

yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y
yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
yum-config-manager --enable remi-php74

# Installation of PHP 7.4 and wordpress dependencies of PHP 

yum install php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo  -y


# Adding rule in firewall

sudo firewall-cmd --permanent --zone=public --add-service=http 
sudo firewall-cmd --permanent --zone=public --add-service=https
sudo firewall-cmd --reload

# Downloading Mysql rpm bundle

clear

echo "
*****************************************************************

	Downloading Mysql Package
	
	Please wait ......

*****************************************************************
"

cd ~ 
mkdir rpm_mysql
cd rpm_mysql
wget https://downloads.mysql.com/archives/get/p/23/file/mysql-5.7.33-1.el7.x86_64.rpm-bundle.tar
tar -xvf mysql-5.7.33-1.el7.x86_64.rpm-bundle.tar

# 

clear

echo "
*****************************************************************

	Installing Mysql....

*****************************************************************
"

yum install mysql-community-{server,client,common,libs}-* -y
systemctl start mysqld

clear

echo "
*********************************************

        MYSQL INSTALLATION COMPLETED

*********************************************
"

clear

echo "

	Securing Mysql...

"


read -p 'Enter the password for MYSQL root account: ' MYSQL_ROOT_PASSWORD
# MYSQL_ROOT_PASSWORD='Password@123'
MYSQL=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')

SECURE_MYSQL=$(expect -c "

set timeout 10
spawn mysql_secure_installation

expect \"Enter password for user root:\"
send \"$MYSQL\r\"
expect \"New password:\"
send \"$MYSQL_ROOT_PASSWORD\r\"
expect \"Re-enter new password:\"
send \"$MYSQL_ROOT_PASSWORD\r\"
expect \"Change the password for root ?\ ((Press y\|Y for Yes, any other key for No) :\"
send \"y\r\"
send \"$MYSQL\r\"
expect \"New password:\"
send \"$MYSQL_ROOT_PASSWORD\r\"
expect \"Re-enter new password:\"
send \"$MYSQL_ROOT_PASSWORD\r\"
expect \"Do you wish to continue with the password provided?\(Press y\|Y for Yes, any other key for No) :\"
send \"y\r\"
expect \"Remove anonymous users?\(Press y\|Y for Yes, any other key for No) :\"
send \"y\r\"
expect \"Disallow root login remotely?\(Press y\|Y for Yes, any other key for No) :\"
send \"n\r\"
expect \"Remove test database and access to it?\(Press y\|Y for Yes, any other key for No) :\"
send \"y\r\"
expect \"Reload privilege tables now?\(Press y\|Y for Yes, any other key for No) :\"
send \"y\r\"
expect eof
")

echo $SECURE_MYSQL

# Creating database and wordpress user in MYSQL

mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE wordpress;"
mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE USER wordpressuser@localhost IDENTIFIED BY 'Wordpress@123';"
mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON wordpress.* TO wordpressuser@localhost IDENTIFIED BY 'Wordpress@123';"
mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "FLUSH PRIVILEGES;"


# Downloading wordpress package

clear
echo "

		Installing Wordpress ....

"

cd ~
wget http://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
rsync -avP ~/wordpress/ /var/www/html/
mkdir /var/www/html/wp-content/uploads
chown -R apache:apache /var/www/html/*


cd /var/www/html/
cp wp-config-sample.php wp-config.php


sed -i "23s/database_name_here/wordpress/" /var/www/html/wp-config.php
sed -i "26s/username_here/wordpressuser/" /var/www/html/wp-config.php
sed -i "29s/password_here/Wordpress@123/" /var/www/html/wp-config.php

cd ~

touch wordpress_credential

echo "

DATABASE NAME = wordpress

USER NAME = wordpressuser

DATABASE PASSWORD = Wordpress@123

" > wordpress_credential

echo "

	You can open wordpress now using your this machine ip like 
	

	Please find your wordpress deatails inside [wordpress_credential] file of your home directory..

	starting wordpress ....
"

sudo service httpd restart

