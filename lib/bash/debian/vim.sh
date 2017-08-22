#!/bin/bash

if which vim > /dev/null; then
  echo "Found vim installation"
else
  echo "vim installation"
  apt-get install -y vim
fi

