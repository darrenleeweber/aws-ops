#!/bin/sh

if which firefox > /dev/null; then
  echo "Found firefox installation"
else
  echo "firefox installation"
  apt-get -y install firefox
fi
