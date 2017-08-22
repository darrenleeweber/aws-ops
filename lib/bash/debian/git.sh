#!/bin/bash

if which git > /dev/null; then
  echo "Found git installation"
else
  echo "git installation"
  apt-get install -y -qq git git-doc git-man gitk
fi

