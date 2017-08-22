#!/bin/bash

if [ -d /usr/lib/jvm/java-7-oracle ]; then
    echo "Found java-7-oracle installation"
elif [ -d /usr/lib/jvm/java-8-oracle ]; then
    echo "Found java-8-oracle installation"
else
    echo "Common Oracle java installation"
    apt-get install -y -q python-software-properties
    add-apt-repository ppa:webupd8team/java
    apt-get update -qq
    echo debconf shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
    echo debconf shared/accepted-oracle-license-v1-1 seen true   | /usr/bin/debconf-set-selections
fi
