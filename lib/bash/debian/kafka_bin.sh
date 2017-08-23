#!/bin/bash

# See also https://gist.github.com/monkut/07cd1618102cbae8d587811654c92902
# See also https://www.digitalocean.com/community/tutorials/how-to-install-apache-kafka-on-ubuntu-14-04

# Dependencies (are not installed by this script)
# - java (runtime)
# - zookeeper (runtime)

# Create a user for Kafka
# - this requires an interactive shell, so it's commented out here.
# - try the solutions in https://askubuntu.com/questions/94060/run-adduser-non-interactively

#useradd kafka -m
#passwd kafka
#adduser kafka sudo
#su - kafka

# The KAFKA_HOME is a symlink to a Kafka version directory
if [ ! -f /etc/profile.d/kafka.sh ]; then
    echo 'export KAFKA_HOME=/usr/local/kafka' | sudo tee -a /etc/profile.d/kafka.sh
fi
source /etc/profile.d/kafka.sh
export KAFKA_INSTALL_DIR=$(dirname ${KAFKA_HOME})

# Check if it's installed already

SCALA_VER=2.11
VER=0.11.0.0
BIN="kafka_${SCALA_VER}-${VER}"
TAR="${BIN}.tgz"

if ls -d ${KAFKA_INSTALL_DIR}/${BIN} > /dev/null 2&>1; then
    echo "Found Kafka installed already in:"
    ls -d ${KAFKA_INSTALL_DIR}/${BIN}
    exit 0
else
    echo "Did not find Kafka installed in: ${KAFKA_INSTALL_DIR}/${BIN}"
fi


# ---
# Download binary release and install it
mkdir -p ~/Downloads/apache-kafka
cd ~/Downloads/apache-kafka
wget -q -nc https://archive.apache.org/dist/kafka/${VER}/${TAR}

#http://mirror.olnevhost.net/pub/apache/kafka/${VER}/${TAR}

# ---
# Install to KAFKA_INSTALL_DIR and create symlink to KAFKA_HOME
tar -zxf ${TAR} -C ${KAFKA_INSTALL_DIR}/
# remove any existing symlink (it might not exist)
rm -f ${KAFKA_HOME}
# create the KAFKA_HOME symlink
ln -s ${KAFKA_INSTALL_DIR}/${BIN} ${KAFKA_HOME}


# ---
# Cleanup
#rm -rf kafka*

# Completed installation


## ---
## Setup and start kafka
## - default zookeeper configuration and service running is assumed
## - using default config/server.properties
#
#sudo mkdir -p /usr/local/kafka/logs
#sudo chmod a+rwx /usr/local/kafka/logs
#
#/usr/local/kafka/bin/kafka-server-start.sh -daemon /usr/local/kafka/config/server.properties




####
## Examples of using kafka
#
## list all the topics (should be zero for first installation)
#/usr/local/kafka/bin/kafka-topics.sh --zookeeper localhost:2181 --list
#
## create a 'test' topic
## - replication-factor must be 1 because there is only one broker (one node)
#/usr/local/kafka/bin/kafka-topics.sh --zookeeper localhost:2181 --create   --topic test --partitions 2 --replication-factor 1 --if-not-exists
#/usr/local/kafka/bin/kafka-topics.sh --zookeeper localhost:2181 --describe --topic test
#
## use console utils to observe pub/sub activity
## - use screen to create a vertical split window for the producer and consumer:
##   - `^A |` to split vertically and `^A tab` to jump between them
##   - `^A c` to create a new session in the right side window
#
## - in the left window, create the producer using:
#/usr/local/kafka/bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test
#
## - in the right window, create the consumer using:
#/usr/local/kafka/bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic test


