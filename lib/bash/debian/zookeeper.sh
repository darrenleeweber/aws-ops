#!/bin/sh

if [ -d /usr/share/doc/zookeeperd ]; then
  echo "skip zookeeper installation"
else
  echo "zookeeper installation"
  apt-get install -y zookeeper
  apt-get install -y zookeeperd
  apt-get install -y zookeeper-bin
fi

