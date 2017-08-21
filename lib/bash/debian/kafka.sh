
# See also https://gist.github.com/monkut/07cd1618102cbae8d587811654c92902

VER=0.10.2.0
SRC="kafka-${VER}-src"

# ---
# Download
wget https://archive.apache.org/dist/kafka/${VER}/${SRC}.tgz
tar -zxf ${SRC}.tgz

# ---
# Build
cd ${SRC}
gradle
./gradlew jar
./gradlew releaseTarGz -x signArchives

# ---
# Install
cd ../
DIST=$(basename ${SRC}/core/build/distributions/kafka_*-${VER}.tgz .tgz)
tar zxf ${SRC}/core/build/distributions/${DIST}.tgz -C /usr/local/
rm -f /usr/local/kafka
ln -s /usr/local/$DIST /usr/local/kafka

# ---
# Cleanup
rm -rf kafka*

# ---
# Add user
#useradd kafka -m


# ---
# Setup and start kafka
# - default zookeeper configuration and service running is assumed
# - using default config/server.properties

sudo mkdir -p /usr/local/kafka/logs
sudo chmod a+rwx /usr/local/kafka/logs

/usr/local/kafka/bin/kafka-server-start.sh -daemon /usr/local/kafka/config/server.properties


# Completed installation and startup
exit


###
# Examples of using kafka

# list all the topics (should be zero for first installation)
/usr/local/kafka/bin/kafka-topics.sh --zookeeper localhost:2181 --list

# create a 'test' topic
# - replication-factor must be 1 because there is only one broker (one node)
/usr/local/kafka/bin/kafka-topics.sh --zookeeper localhost:2181 --create   --topic test --partitions 2 --replication-factor 1 --if-not-exists
/usr/local/kafka/bin/kafka-topics.sh --zookeeper localhost:2181 --describe --topic test

# use console utils to observe pub/sub activity
# - use screen to create a vertical split window for the producer and consumer:
#   - `^A |` to split vertically and `^A tab` to jump between them
#   - `^A c` to create a new session in the right side window

# - in the left window, create the producer using:
/usr/local/kafka/bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test

# - in the right window, create the consumer using:
/usr/local/kafka/bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic test


