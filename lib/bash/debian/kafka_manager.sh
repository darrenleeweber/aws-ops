
# ---
# Download
git clone https://github.com/yahoo/kafka-manager


# ---
# Build
cd kafka-manager
sbt debian:packageBin


exit


# ---
# Install
cd ../
DIST=$(basename ${SRC}/core/build/distributions/kafka_*-${VER}.tgz .tgz)
tar zxf ${SRC}/core/build/distributions/${DIST}.tgz -C /usr/local/
rm -f /usr/local/kafka
ln -s /usr/local/$DIST /usr/local/kafka



