#!/bin/bash
##denisrosenkranz.com##
##Web Server Management script##

echo "#############################################"
echo "########Web Server management Script#########"
echo "#############################################"
echo ""
echo "What you want to do?"
echo " "

echo "1. Create User"
echo "2. Create Domain"
echo "3. Create SSL Domain"
echo "4. Delete User"
echo "5. Delete Domain"
echo "6. Delete SSL Domain"
echo "7. Exit"
read choice

case $choice in

	1)
	echo "Username: "
	read user
	echo "Password: "
	read pass
	echo "Domain name: "
	read domain
	echo "Email address: "
	read mail
	
	##On créer un user
	useradd -s /sbin/nologin $user

	#On met un mot de passe
	echo $pass | passwd --stdin $user

	##Création de son dossier www
	mkdir /home/$user/www
	chmod -R 755 /home/$user
	usermod -a -G apache $user
	chown -R $user. /home/$user/www
	chgrp -R apache /home/$user/www
	


	##Database setup
	dbname="$user"_db
	mysql -u root -proot -e "CREATE DATABASE IF NOT EXISTS $dbname;GRANT ALL PRIVILEGES ON $dbname.* TO $user@localhost IDENTIFIED BY '$pass';FLUSH PRIVILEGES;"
	;;
	
	2)
	
	3)
	

	4)
	echo "Username: "
	read user
	echo "Domain name: "
	read domain	
	systemctl stop httpd
	
	./letsencrypt-auto certonly --standalone -d $domain

	echo 'SSLPassPhraseDialog  builtin
SSLSessionCache         shmcb:/var/cache/mod_ssl/scache(512000)
SSLSessionCacheTimeout  300
SSLMutex default

SSLRandomSeed startup file:/dev/urandom  256
SSLRandomSeed connect builtin

SSLCryptoDevice builtin

<VirtualHost *:443>

SSLEngine on

DocumentRoot "/home/$user/www"
ServerName $domain:443

ErrorLog logs/ssl_error_log
TransferLog logs/ssl_access_log
LogLevel warn

SSLProtocol all -SSLv2 -SSLv3

SSLCipherSuite "HIGH:!aNULL:!eNULL:!kECDH:!aDH:!RC4:!3DES:!CAMELLIA:!MD5:!PSK:!SRP:!KRB5:@STRENGTH"

SSLCertificateFile /etc/letsencrypt/live/$domain/cert.pem
SSLCertificateChainFile /etc/letsencrypt/live/$domain/chain.pem
SSLCertificateKeyFile /etc/letsencrypt/live/$domain/privkey.pem

SSLVerifyClient none
SSLVerifyDepth  1

<Files ~ "\.(cgi|shtml|phtml|php3?)$">
    SSLOptions +StdEnvVars
</Files>
<Directory "/var/www/cgi-bin">
    SSLOptions +StdEnvVars
</Directory>
<Directory />
Allowoverride All
</Directory>

CustomLog logs/ssl_request_log \
          "%t %h %{SSL_PROTOCOL}x %{SSL_CIPHER}x \"%r\" %b"

</VirtualHost>' > /etc/httpd/conf.d/$user_ssl.conf

	systemctl start httpd
	;;

	5)
	echo "Username of the user you want to delete:"
	read user
	userdel $user
	dbname="$user"_db
	rm -rvf /home/$user
	rm /etc/httpd/conf.d/$user.conf
	mysql -u root -proot -e "DROP USER $user@localhost;DROP DATABASE $dbname;"
	;;

esac	



