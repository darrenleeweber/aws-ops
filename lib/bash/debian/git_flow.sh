#!/bin/bash

if git flow init help | grep -q 'usage: git flow'; then
  echo "Found git-flow installation"
else
  echo "git-flow installation"
  apt-get install -y git-flow
fi
