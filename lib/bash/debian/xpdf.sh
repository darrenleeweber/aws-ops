#!/bin/sh

if which xpdf > /dev/null; then
  echo "Found xpdf installation"
else
  echo "xpdf installation"
  apt-get install -y xpdf
fi
