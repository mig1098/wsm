#!/bin/bash
##denisrosenkranz.com##
##Web Server Management script##

echo "#############################################"
echo "########Web Server management Script#########"
echo "#############################################"
echo ""
echo "What you want to do?"
echo " "

echo "1. Install LAMP Stack and VsFTPd"
echo "2. Install Lets's Encrypt"
echo "3. Create new user with virtualhost and database"
echo "4. Create SSL VirtualHost with Let's encrypt"
echo "5. Delete an user"
echo "6. Restart services"
echo "7. Exit"
read choice

case $choice in

	1)
	##CentOS
	##MAj des paquets
	yum update -y

	##Installation Apache,PHP,MySQL,VsFTPD
	yum install httpd php php-mysql php-gd php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php-snmp php-soap mariadb-server vsftpd -y

	##Launch http and MariaDB
	systemctl start mariadb
	systemctl start httpd

	#Configuration de MariaDB
	mysql_secure_installation <<EOF

y
root
root
y
y
y
y
EOF
	
	#Configure VsFTPd
	echo 'chroot_local_user=YES
user_sub_token=$USER
local_root=/home/$USER/www' >> /etc/vsftpd/vsftpd.conf
	systemctl start vsftpd

	#Start the services on boot
	systemctl enable mariadb
	systemctl enable httpd
	systemctl enable vsftpd
	;;

	2)
	yum install git -y
	git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt
	;;
	
	3)
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
	mkdir -p /home/$user/www
	chmod -R 755 /home/$user

	##VirtualHost setup

	echo "<VirtualHost *:80>
ServerAdmin $mail
DocumentRoot /home/$user/www/
ServerName $domain
DirectoryIndex index.html index.php

	<Directory /home/$user/www/>
		Options Indexes FollowSymLinks MultiViews
		AllowOverride None
		Order allow,deny
		allow from all
	</Directory>

	ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
	    	
	<Directory "/usr/lib/cgi-bin">
		AllowOverride None
		Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
		Order allow,deny
		Allow from all
	</Directory>
</VirtualHost>" > /etc/httpd/conf.d/$user.conf

	##Database setup
	dbname="$user"_db
	mysql -u root -proot -e "CREATE DATABASE IF NOT EXISTS $dbname;GRANT ALL PRIVILEGES ON $dbname.* TO $user@localhost IDENTIFIED BY '$pass';FLUSH PRIVILEGES;"
	;;

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



