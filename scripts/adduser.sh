#!/bin/bash
##denisrosenkranz.com##
##Web Server Management script##

WSM=/opt/wsm

EXPECTED_ARGS=4
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: $0 username password domain mail"
  exit $E_BADARGS
fi
	
##On créer un user
useradd -s /sbin/nologin $1

#On met un mot de passe
echo $2 | passwd --stdin $1

##Création de son dossier www
mkdir /home/$1/www
chmod -R 755 /home/$1
usermod -a -G apache $1
chown -R $1. /home/$1/www
chgrp -R apache /home/$1/www
	
##Database setup
dbname="$1"_db
mysql -u root -proot -e "CREATE DATABASE IF NOT EXISTS $dbname;GRANT ALL PRIVILEGES ON $dbname.* TO $1@localhost IDENTIFIED BY '$pass';FLUSH PRIVILEGES;"

sed 's/user/'$1'/g' $WSM/template-apache-2.4.conf > /etc/httpd/conf.d/$1.tmp1
sed 's/domain/'$3'/g' /etc/httpd/conf.d/$1.tmp1 > /etc/httpd/conf.d/$1.tmp2
sed 's/mail/'$4'/g' /etc/httpd/conf.d/$1.tmp2 > /etc/httpd/conf.d/$1.conf
rm /etc/httpd/conf.d/$1.tmp* -f

systemctl reload httpd
