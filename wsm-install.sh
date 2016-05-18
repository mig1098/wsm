!/bin/bash
##denisrosenkranz.com##
##Web Server Management Install##

echo "#############################################"
echo "########Web Server management installation#########"
echo "#############################################"
echo ""
echo ""
git
##CentOS
##MAj des paquets
echo "update Centos"
yum update -y
echo "Done !"

echo "LAMP Instalation"
##Installation Apache,PHP,MySQL
yum install httpd php php-mysql php-gd php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php-snmp php-soap mariadb-server -y
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

echo "#############################################"
echo "#######Web Server management installation####"
echo "##################Completed##################"
echo ""
echo ""

