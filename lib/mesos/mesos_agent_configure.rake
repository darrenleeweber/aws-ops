require_relative 'mesos_agent_helpers'

namespace :mesos_agent do
  namespace :service do
    MESOS_HOME_DEFAULT = '/opt/mesos_agent'.freeze

    def mesos_agent_home
      host_settings['mesos_agent_home'] || MESOS_HOME_DEFAULT
    end

    def mesos_agent_ver
      settings = host_settings
      [
        settings['scala_version'] || '2.11',
        settings['mesos_agent_version '] || '0.11.0.0'
      ].join(' ')
    end

    def zookeeper_connections
      ZookeeperHelpers.connections.join(',')
    end

    ###############################
    # Configuration notes
    #
    # Modify the `server.properties` file in each broker:
    # - the broker.id should be unique for each broker
    # - the zookeeper.connect should be set to point to the same
    #   ZooKeeper instances
    # - for multiple ZooKeeper instances, the zookeeper.connect should be a
    #   comma-separated string listing the IP addresses and port numbers
    #   of all the ZooKeeper instances.

    desc 'Configure service'
    task :configure do
      # on roles(:mesos_agent), in: :parallel do |host|
      #   # Replace the content in ${MESOS_HOME}/config/server.properties
      #   config_file = capture("ls #{mesos_agent_home}/config/server.properties")
      #
      #   # Set broker.id
      #   broker_id = host_settings['broker_id']
      #   sudo("sed -i -e 's/broker.id=.*/broker.id=#{broker_id}/' #{config_file}")
      #
      #   # Set zookeeper.connect
      #   zoo_connect = "zookeeper.connect=#{zookeeper_connections}"
      #   sudo("sed -i -e 's/zookeeper.connect=.*/#{zoo_connect}/' #{config_file}")
      #
      #   # Setup the /etc/hosts file for zookeeper nodes, using private IPs
      #   etc_hosts_new = ZookeeperHelpers.manager.etc_hosts(false) # use private IPs
      #   # remove any existing server entries in /etc/hosts
      #   sudo("sed -i -e '/BEGIN_ZOO_SERVERS/,/END_ZOO_SERVERS/{ d; }' /etc/hosts")
      #   # append new entries to the /etc/hosts file (one line at a time)
      #   sudo("echo '### BEGIN_ZOO_SERVERS' | sudo tee -a /etc/hosts > /dev/null")
      #   # append new entries to the /etc/hosts file (one line at a time)
      #   etc_hosts_new.each do |etc_host|
      #     sudo("echo '#{etc_host}' | sudo tee -a /etc/hosts > /dev/null")
      #   end
      #   sudo("echo '### END_ZOO_SERVERS' | sudo tee -a /etc/hosts > /dev/null")
      #
      #   # TODO: advertised.listeners=PLAINTEXT://your.host.name:9092
      # end
    end
  end
end

