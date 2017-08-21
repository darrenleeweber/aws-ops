#!/bin/sh

if [ -d /usr/share/doc/zookeeperd ]; then
  echo "skip zookeeper installation"
else
  echo "zookeeper installation"
  apt-get install -y -q zookeeper zookeeperd zookeeper-bin
fi

