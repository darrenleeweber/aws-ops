#!/bin/bash

if which mvn > /dev/null; then
  echo "Found maven installation"
else
  echo "maven installation"
  apt-get install -y -qq maven
fi

