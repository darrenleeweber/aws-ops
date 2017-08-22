#!/bin/bash

if which mysqld > /dev/null; then
  echo "Found mysql installation"
else
  echo "mysql installation"
  DB_PASS='root4mysql'
  echo "mysql-server mysql-server/root_password password $DB_PASS"       | debconf-set-selections
  echo "mysql-server mysql-server/root_password_again password $DB_PASS" | debconf-set-selections
  apt-get install -y mysql-server
  # mysql_secure_installation
  # mysqladmin -u root password "$DB_PASS"
  mysql -u root -p"$DB_PASS" -e "UPDATE mysql.user SET Password=PASSWORD('$DB_PASS') WHERE User='root'"
  mysql -u root -p"$DB_PASS" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
  mysql -u root -p"$DB_PASS" -e "DELETE FROM mysql.user WHERE User=''"
  mysql -u root -p"$DB_PASS" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
  mysql -u root -p"$DB_PASS" -e "FLUSH PRIVILEGES"
fi
