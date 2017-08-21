echo "Installing Blazegraph"

BLAZEGRAPH_VERSION=BLAZEGRAPH_RELEASE_2_1_4

SHARED_DIR=$1

if [ -f "$SHARED_DIR/scripts/config" ]; then
  . $SHARED_DIR/scripts/config
fi

if [ ! -d /etc/blazegraph ]; then
  echo -n "Downloading Blazegraph..."
  cd $DOWNLOAD_DIR
  git clone -b $BLAZEGRAPH_VERSION --single-branch https://github.com/blazegraph/database.git $BLAZEGRAPH_VERSION
  chown -hR vagrant:vagrant $BLAZEGRAPH_VERSION
  cd $BLAZEGRAPH_VERSION/blazegraph-deb/
  mvn clean package
  sudo apt-get update
  sudo apt-get install -y python-software-properties
  sudo dpkg --install ./target/blazegraph-deb-2.1.4.deb 

  # The installer echoes the following:
  #
  # ***********************************************************
  # * The following kernel tuning parameters are recommended. *
  # * They are not automatically configured.                  *
  # ***********************************************************
  # 
  # echo 1 > /proc/sys/net/ipv4/tcp_tw_reuse
  # echo 'vm.swappiness = 0' >> /etc/sysctl.d/10-vm.swappiness.conf
  # sysctl -p || true >& /dev/null

  # When trying to follow these instructions, the system does not allow modification to these files.
  #
  #sudo echo 1 > /proc/sys/net/ipv4/tcp_tw_reuse
  #sudo echo 'vm.swappiness = 0' >> /etc/sysctl.d/10-vm.swappiness.conf
  #sudo sysctl -p || true >& /dev/null

  sudo apt-get install -f -y
  sudo service blazegraph restart

  echo " done"
fi

