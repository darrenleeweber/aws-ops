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
    echo debconf shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
    echo debconf shared/accepted-oracle-license-v1-1 seen true   | /usr/bin/debconf-set-selections
fi

