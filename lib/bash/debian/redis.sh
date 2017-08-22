#!/bin/bash

if which redis-server > /dev/null; then
  echo "Found redis installation"
else
  echo "redis installation"
  apt-get install -y redis-server
fi

echo "See also http://redisdesktop.com/"
