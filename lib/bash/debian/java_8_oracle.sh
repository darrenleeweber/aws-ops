#!/bin/bash

# This script depends on the ./java_oracle_license.sh for installation of Oracle java dependencies

if [ -d /usr/lib/jvm/java-8-oracle ]; then
  echo "Found java-8-oracle installation"
else
    echo "java 8 installation"
    apt-get install -y -q oracle-java8-installer
    yes "" | apt-get -f install
fi
