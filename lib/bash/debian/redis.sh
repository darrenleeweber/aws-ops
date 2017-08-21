#!/bin/sh

if which redis-server >/dev/null; then
  echo "skip redis installation"
else
  echo "redis installation"
  apt-get install -y redis-server
fi

echo "See also http://redisdesktop.com/"
