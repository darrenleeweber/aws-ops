#!/bin/bash

if which htop > /dev/null; then
  echo "Found htop installation"
else
  echo "htop installation"
  apt-get install -y -qq htop
fi

