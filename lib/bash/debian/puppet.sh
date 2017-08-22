#!/bin/bash

if which puppet > /dev/null; then
  echo "Found puppet installation"
else
  echo "puppet installation"
  apt-get install -y -q puppet
fi

