#!/bin/bash

# This script depends on the ./java_oracle_license.sh for installation of Oracle java dependencies

if [ -d /usr/lib/jvm/java-7-oracle ]; then
    echo "Found java-7-oracle installation"
else
    echo "java 7 installation"
    apt-get install -y -q oracle-java7-installer
    yes "" | apt-get -f install
fi
