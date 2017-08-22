#!/bin/bash

# Disable RAM Swap on a zookeeper node

if grep -E -q '^vm.swappiness=1' /etc/sysctl.conf; then
    echo "Found vm.swappiness=1 in /etc/sysctl.conf"
else
    sysctl vm.swappiness=1
    echo 'vm.swappiness=1' | tee --append /etc/sysctl.conf
fi
