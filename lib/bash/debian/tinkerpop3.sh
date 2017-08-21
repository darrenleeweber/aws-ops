#!/usr/bin/env bash

#export shared_path=$1
#export HOST_IP=$2

# Download and Unpack
if [ ! -d apache-tinkerpop-gremlin-server-3.2.4 ]; then
    echo "Installing TinkerPop Gremlin-Server"
    wget http://apache.mirrors.lucidnetworks.net/tinkerpop/3.2.4/apache-tinkerpop-gremlin-server-3.2.4-bin.zip
    unzip apache-tinkerpop-gremlin-server-3.2.4-bin.zip
fi

if [ ! -d apache-tinkerpop-gremlin-console-3.2.4 ]; then
    echo "Installing TinkerPop Gremlin-Console"
    wget http://apache.mirrors.lucidnetworks.net/tinkerpop/3.2.4/apache-tinkerpop-gremlin-console-3.2.4-bin.zip
    unzip apache-tinkerpop-gremlin-console-3.2.4-bin.zip
fi

if [ ! -d tinkerpop-3.2.4 ]; then
    echo "Installing TinkerPop Source"
    wget http://apache.mirrors.lucidnetworks.net/tinkerpop/3.2.4/apache-tinkerpop-3.2.4-src.zip
    unzip apache-tinkerpop-3.2.4-src.zip
fi


exit


# Older versions

wget https://archive.apache.org/dist/incubator/tinkerpop/3.0.2-incubating/apache-gremlin-console-3.0.2-incubating-bin.zip
wget https://archive.apache.org/dist/incubator/tinkerpop/3.0.2-incubating/apache-gremlin-server-3.0.2-incubating-bin.zip
wget https://archive.apache.org/dist/incubator/tinkerpop/3.0.2-incubating/apache-tinkerpop-3.0.2-incubating-src.zip

wget http://apache.mirrors.lucidnetworks.net/tinkerpop/3.1.6/apache-tinkerpop-gremlin-console-3.1.6-bin.zip
wget http://mirror.cogentco.com/pub/apache/tinkerpop/3.1.6/apache-tinkerpop-gremlin-server-3.1.6-bin.zip
wget http://supergsego.com/apache/tinkerpop/3.1.6/apache-tinkerpop-3.1.6-src.zip

