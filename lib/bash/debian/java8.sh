#!/bin/sh

# This script depends on the ./java.sh for installation of Oracle java dependencies

echo "java 8 installation"
apt-get install -y -q oracle-java8-installer
yes "" | apt-get -f install
