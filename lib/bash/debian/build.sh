#!/bin/bash

if [ -d /usr/share/build-essential ]; then
    echo "Found build-essential installation"
else
    apt-get install -y -qq build-essential
fi
