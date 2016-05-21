#!/bin/bash
##denisrosenkranz.com##
##Web Server Management Install##

WSM=/opt/wsm

echo "#############################################"
echo "########Web Server management installation#########"
echo "#############################################"
echo ""
echo ""

##CentOS
##MAj des paquets
echo "update Centos"
yum update -y
echo "Done !"

echo "LAMP Instalation"
##Installation Apache,PHP,MySQL
yum install httpd php php-mysql php-gd php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php-snmp php-soap mariadb-server wget -y

echo "NameVirtualHost *:80" >> /etc/httpd/conf/httpd.conf

echo "Install PHPMyadmin"
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -i epel-release-7-1.noarch.rpm -y
yum install phpmyadmin -y

cp $WSM/templates/phpMyAdmin.conf /etc/httpd/conf.d/phpMyAdmin.conf

echo "Done"
##Launch http and MariaDB
systemctl start mariadb
systemctl start httpd

echo "Configure MariaDB"
#Configuration de MariaDB
mysql_secure_installation <<EOF

n
y
y
y
y
EOF
echo "Done"

echo "VsFTPd Installation"
yum install -y vsftpd	
#Configure VsFTPd
echo 'chroot_local_user=YES
user_sub_token=$USER
local_root=/home/$USER/www' >> /etc/vsftpd/vsftpd.conf
 echo "Done !"
systemctl start vsftpd

#Start the services on boot
systemctl enable mariadb
systemctl enable httpd
systemctl enable vsftpd

echo "Let's Encrypt installation"
yum install git -y
git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt

echo "Done !"

echo "#############################################"
echo "#######Web Server management installation####"
echo "##################Completed##################"
echo ""
echo ""

