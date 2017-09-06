#!/bin/bash

if ! grep -q '^deb.*webupd8team/java' /etc/apt/sources.list /etc/apt/sources.list.d/*; then
    apt-get install -y -q python-software-properties
    add-apt-repository -y ppa:webupd8team/java
    apt-get -y -q update
fi
