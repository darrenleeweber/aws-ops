#!/usr/bin/env bash

if which kafka-manager; then
    echo "Kafka manager is installed"
    exit
fi

curl -s https://packagecloud.io/install/repositories/spuder/kafka-manager/script.deb.sh | sudo bash

sudo apt-get install -y -q kafka-manager


#---
# Enable systemd
# https://github.com/yahoo/kafka-manager/issues/373

cat > /tmp/kafka-manager.service <<EOF
[Unit]
Description=Kafka Manager
After=network.target

[Install]
WantedBy=multi-user.target

[Service]
ExecStart=/usr/bin/kafka-manager -Dpidfile.path=/var/run/kafka-manager.pid -Dconfig.file=/etc/kafka-manager/application.conf -Dlogger.file=/etc/kafka-manager/logger.xml
Type=simple
Restart=always
EOF

sudo mv /tmp/kafka-manager.service /lib/systemd/system/
sudo chown root:root /lib/systemd/system/kafka-manager.service
sudo chmod 644       /lib/systemd/system/kafka-manager.service
sudo systemctl enable kafka-manager.service

# TODO: Create 'kafka' user/group to run the service

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
