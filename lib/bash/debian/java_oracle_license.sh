#!/bin/bash

# If Oracle java is already installed, the license is already accepted.
if [ -d /usr/lib/jvm/java-9-oracle ]; then
    echo "Found at least one Oracle java installation - java-9-oracle"
elif [ -d /usr/lib/jvm/java-8-oracle ]; then
    echo "Found at least one Oracle java installation - java-8-oracle"
elif [ -d /usr/lib/jvm/java-7-oracle ]; then
    echo "Found at least one Oracle java installation - java-7-oracle"
else
    echo "Common Oracle java license acceptance"
    apt-get install -y -q python-software-properties > /dev/null
    add-apt-repository -y ppa:webupd8team/java > /dev/null 2&>1
    apt-get -y -q update > /dev/null
    echo debconf shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
    echo debconf shared/accepted-oracle-license-v1-1 seen true   | /usr/bin/debconf-set-selections
fi
