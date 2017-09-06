#!/bin/bash

if which docker > /dev/null; then
  echo "Found docker installation"
  exit
fi

# https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/
# https://docs.docker.com/engine/installation/linux/linux-postinstall/

# remove old package names, if they exist

apt-get remove -y -qq docker docker-engine docker.io

apt-get install -y -qq \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Verify that the key fingerprint is 9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88.
#apt-key fingerprint 0EBFCD88

#pub   4096R/0EBFCD88 2017-02-22
#Key fingerprint = 9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88
#uid                  Docker Release (CE deb) <docker@docker.com>
#sub   4096R/F273FCD8 2017-02-22

add-apt-repository -y \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update

# Install the latest version
apt-get install -y -q docker-ce docker-compose

# On production - install a particular version, e.g.
# List the available versions.
#apt-cache madison docker-ce
#apt-get install docker-ce=<VERSION>

# configure docker to start on boot
systemctl enable docker

