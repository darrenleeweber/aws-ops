#!/bin/sh

if which mongod > /dev/null; then
  echo "Found mongodb installation"
else
  echo "mongodb installation"
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
  echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.0.list
  apt-get update -qq
  apt-get -y install mongodb-org
fi
