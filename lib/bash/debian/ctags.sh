#!/bin/sh

if which ctags > /dev/null; then
  echo "Found ctags installation"
else
  echo "ctags installation"
  apt-get install -y exuberant-ctags
fi
