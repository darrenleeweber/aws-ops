#!/bin/bash

if which heroku > /dev/null; then
  echo "Found heroku installation"
else
  echo "heroku installation"
  wget -qO- https://toolbelt.heroku.com/install-ubuntu.sh | sh
fi
