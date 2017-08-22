#!/bin/bash

if which gradle > /dev/null; then
  echo "Found gradle installation"
else
  echo "gradle installation"
  apt-get install -y -qq gradle
fi

