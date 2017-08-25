#!/bin/bash

install_package() {
    package=$1
    if [ -d "/usr/share/doc/${package}" ]; then
        echo "Found ${package} installation"
    else
        apt-get install -y -qq ${package}
    fi
}

install_package ca-certificates
install_package netcat
install_package net-tools
install_package pssh
install_package tar
install_package wget
install_package zip

