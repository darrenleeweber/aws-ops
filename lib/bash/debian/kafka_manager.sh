#!/usr/bin/env bash

if [ -d /usr/share/kafka-manager ]; then
    echo "Kafka manager is installed"
    exit
fi


curl -s https://packagecloud.io/install/repositories/spuder/kafka-manager/script.deb.sh | sudo bash

sudo apt install kafka-manager

exit


# ---
# Download
cd /tmp
git clone https://github.com/yahoo/kafka-manager


# ---
# Build
cd kafka-manager
sbt debian:packageBin


# ---
# Install

sudo dpkg -i -R target/

# dpkg -L kafka-manager

# ---
# Cleanup

sbt clean clean-files
