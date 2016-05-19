#!/bin/bash
##denisrosenkranz.com##
##Web Server Management script##

WSM=/opt/wsm

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
	
	cp $WSM/template-apache-2.4.conf /etc/http/conf.d/$user.conf
	sed 's/user/'$user'/g' $WSM/template-apache-2.4.conf > /etc/httpd/conf.d/$user.tmp1
	sed 's/domain/'$domain'/g' /etc/httpd/conf.d/$user.tmp1 > /etc/httpd/conf.d/$user.tmp2
	sed 's/mail/'$mail'/g' /etc/httpd/conf.d/$user.tmp2 > /etc/httpd/conf.d/$user.conf

	rm /etc/httpd/conf.d/$user.tmp* -f

	systemctl reload httpd
	
	2)
	
	3)
	

	4)
	echo "Username of the user you want to delete:"
	read user
	userdel $user
	dbname="$user"_db
	rm -rvf /home/$user
	rm /etc/httpd/conf.d/$user.conf
	mysql -u root -proot -e "DROP USER $user@localhost;DROP DATABASE $dbname;"
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



