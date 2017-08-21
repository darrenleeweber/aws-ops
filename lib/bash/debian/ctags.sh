#!/bin/sh

if which ctags >/dev/null; then
  echo "skip ctags installation"
else
  echo "ctags installation"
  apt-get install -y exuberant-ctags
fi
