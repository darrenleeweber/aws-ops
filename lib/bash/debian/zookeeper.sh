#!/bin/bash

if [ -d /usr/share/doc/zookeeperd ]; then
  echo "Found zookeeper installation"
else
  echo "zookeeper installation"
  apt-get install -y -q zookeeper zookeeperd zookeeper-bin
fi

