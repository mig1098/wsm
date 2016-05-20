#!/bin/bash
##denisrosenkranz.com##
##Web Server Management script##

EXPECTED_ARGS=1
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: $0 username"
  exit $E_BADARGS
fi

userdel $1
dbname="$1"_db
rm -rvf /home/$1
rm /etc/httpd/conf.d/$1.conf
mysql -u root -e "DROP USER $1@localhost;DROP DATABASE $dbname;"
