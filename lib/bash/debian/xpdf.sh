#!/bin/sh

if which xpdf >/dev/null; then
  echo "skip xpdf installation"
else
  echo "xpdf installation"
  apt-get install -y xpdf
fi
