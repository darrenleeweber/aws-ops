#!/bin/bash

if [ -d /usr/share/doc/wget ]; then
    echo "Found wget installation"
else
    apt-get install -y -qq wget
fi

if [ -d /usr/share/doc/zip ]; then
    echo "Found zip installation"
else
    apt-get install -y -qq zip
fi

if [ -d /usr/share/doc/tar ]; then
    echo "Found tar installation"
else
    apt-get install -y -qq tar
fi

if [ -d /usr/share/doc/netcat ]; then
    echo "Found netcat installation"
else
    apt-get install -y -qq netcat
fi

if [ -d /usr/share/doc/net-tools ]; then
    echo "Found net-tools installation"
else
    apt-get install -y -qq net-tools
fi

if [ -d /usr/share/doc/ca-certificates ]; then
    echo "Found ca-certificates installation"
else
    apt-get install -y -qq ca-certificates
fi
