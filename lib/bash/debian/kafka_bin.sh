#!/bin/bash
# See also https://gist.github.com/monkut/07cd1618102cbae8d587811654c92902
# See also https://www.digitalocean.com/community/tutorials/how-to-install-apache-kafka-on-ubuntu-14-04

# Dependencies (are not installed by this script)
# - java (runtime)
# - zookeeper (runtime)

# Help info

HELP=$1
if [ "$HELP" == '-h' -o "$HELP" == '--help' ]; then
    echo "$0 [SCALA_VERSION] [KAFKA_VERSION]"
    exit
fi

# Versions

SCALA_VER=$1
if [ -z "$SCALA_VER" ]; then
    SCALA_VER=2.11
fi

KAFKA_VER=$2
if [ -z "$KAFKA_VER" ]; then
    KAFKA_VER=0.11.0.0
fi

KAFKA_BIN="kafka_${SCALA_VER}-${KAFKA_VER}"
KAFKA_TAR="${KAFKA_BIN}.tgz"

echo "Installing $KAFKA_BIN"

# Create a user for Kafka
# - this requires an interactive shell, so it's commented out here.
# - try the solutions in https://askubuntu.com/questions/94060/run-adduser-non-interactively

#useradd kafka -m
#passwd kafka
#adduser kafka sudo
#su - kafka

# ---
# Setup and use the KAFKA_HOME directory
# - it is a symlink to a versioned Kafka installation
# - it is stored permanently in /etc/profile.d/kafka.sh

if [ -z "$KAFKA_HOME" ]; then
    export KAFKA_HOME='/opt/kafka'
fi
if [ ! -f /etc/profile.d/kafka.sh ]; then
    echo "export KAFKA_HOME=${KAFKA_HOME}"       | sudo tee -a /etc/profile.d/kafka.sh
    echo "export PATH=${PATH}:${KAFKA_HOME}/bin" | sudo tee -a /etc/profile.d/kafka.sh
fi
source /etc/profile.d/kafka.sh
export KAFKA_INSTALL_DIR=$(dirname ${KAFKA_HOME})

# ---
# Check if it's installed already
KAFKA_PATH="${KAFKA_INSTALL_DIR}/${KAFKA_BIN}"

if [ -d ${KAFKA_PATH} ]; then
    echo "Found Kafka installed already in: ${KAFKA_PATH}"
    echo "Updating the ${KAFKA_HOME} symlink to use ${KAFKA_PATH}"
    rm -f ${KAFKA_HOME}
    ln -s ${KAFKA_PATH} ${KAFKA_HOME}
    exit 0
else
    echo "Did not find Kafka installed in: ${KAFKA_INSTALL_DIR}/${KAFKA_BIN}"
fi


# ---
# Download binary release and install it
mkdir -p ~/Downloads/apache-kafka
cd ~/Downloads/apache-kafka
wget -q -nc https://archive.apache.org/dist/kafka/${KAFKA_VER}/${KAFKA_TAR}

# check the success of the download
if [ $? -ne 0 ]; then
    echo "Failed to download ${KAFKA_TAR}"
    exit 1
fi


# ---
# Install to KAFKA_INSTALL_DIR and create symlink to KAFKA_HOME
tar -zxf ${KAFKA_TAR} -C ${KAFKA_INSTALL_DIR}/
# create or update the KAFKA_HOME symlink
rm -f ${KAFKA_HOME}
ln -s ${KAFKA_PATH} ${KAFKA_HOME}


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


