#!/bin/sh

if which qtcreator >/dev/null; then
  echo "skip qtcreator installation"
else
  echo "qtcreator installation"
  apt-get install -y qtcreator
fi
