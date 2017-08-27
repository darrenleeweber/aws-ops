require_relative 'mesos_master_helpers'

namespace :mesos_master do
  namespace :nodes do
    desc 'List settings in this project'
    task :check_settings do
      MesosMasterHelpers.settings.nodes.each do |params|
        puts JSON.pretty_generate(JSON.parse(params.to_json))
      end
    end

    desc 'Create nodes'
    task :create do
      MesosMasterHelpers.manager.create_nodes
    end

    desc 'Terminate nodes'
    task :terminate do
      MesosMasterHelpers.manager.terminate_nodes
    end

    desc 'Find and describe all nodes'
    task :find do
      MesosMasterHelpers.manager.describe_nodes
    end

    desc 'Compose public entries for ~/.ssh/config for nodes'
    task :ssh_config_public do
      puts MesosMasterHelpers.manager.ssh_config
    end

    desc 'Compose private entries for ~/.ssh/config for nodes'
    task :ssh_config_private do
      puts MesosMasterHelpers.manager.ssh_config(false)
    end

    desc 'Compose entries for /etc/hosts using public IPs'
    task :etc_hosts_public do
      puts MesosMasterHelpers.manager.etc_hosts.join("\n")
    end

    desc 'Compose entries for /etc/hosts using private IPs'
    task :etc_hosts_private do
      puts MesosMasterHelpers.manager.etc_hosts(false).join("\n")
    end
  end

  namespace :service do
    MESOS_HOME_DEFAULT = '/opt/mesos_master'.freeze

    def host_settings
      # the `host` object is accessible to this method
      Settings.aws[host.hostname]
    end

    def mesos_master_home
      host_settings['mesos_master_home'] || MESOS_HOME_DEFAULT
    end

    def mesos_master_ver
      settings = host_settings
      [
        settings['scala_version'] || '2.11',
        settings['mesos_master_version '] || '0.11.0.0'
      ].join(' ')
    end

    def zookeeper_connections
      ZookeeperHelpers.connections.join(',')
    end

    desc 'Install MesosMaster service'
    task :install do
      # on roles(:mesos_master), in: :parallel do |host|
      #   # PuppetHelpers.puppet_apply('mesos_master.pp')
      #   # Set or update the system ENV for MESOS_HOME and the PATH
      #   # The mesos_master_bin.sh script should install into the MESOS_HOME directory;
      #   # if 'MESOS_HOME=/opt/mesos_master', then it should install
      #   # /opt/mesos_master sym-linked to /opt/mesos_master_{SCALA_VER}-{MESOS-VER}
      #   sudo("sed -i -e '/export MESOS_HOME/d' /etc/profile.d/mesos_master.sh > /dev/null 2>&1 || true")
      #   sudo("echo 'export MESOS_HOME=#{mesos_master_home}' | sudo tee -a /etc/profile.d/mesos_master.sh")
      #   sudo("sed -i -e '/export PATH/d' /etc/profile.d/mesos_master.sh > /dev/null 2>&1 || true")
      #   sudo("echo 'export PATH=${PATH}:#{mesos_master_home}/bin' | sudo tee -a /etc/profile.d/mesos_master.sh")
      #   # Set the scala/mesos_master version to install and do it, check dependencies
      #   sudo("#{current_path}/lib/bash/debian/java_oracle_license.sh  > #{current_path}/log/bash_java_oracle_license.log")
      #   sudo("#{current_path}/lib/bash/debian/java_8_oracle.sh > #{current_path}/log/bash_java_8_oracle.log")
      #   sudo("#{current_path}/lib/bash/debian/mesos_master_bin.sh #{mesos_master_ver} > #{current_path}/log/bash_mesos_master_bin.log")
      # end
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

    desc 'Configure MesosMaster service'
    task :configure do
      # on roles(:mesos_master), in: :parallel do |host|
      #   # Replace the content in ${MESOS_HOME}/config/server.properties
      #   config_file = capture("ls #{mesos_master_home}/config/server.properties")
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

    desc 'Start MesosMaster service'
    task :start do
      # on roles(:mesos_master) do |host|
      #   # Does this command need to use an absolute path to use the default server.properties?
      #   sudo("#{mesos_master_home}/bin/mesos_master-server-start.sh -daemon #{mesos_master_home}/config/server.properties")
      # end
    end

    # desc 'Status of MesosMaster service'
    # task :status do
    #   on roles(:mesos_master) do |host|
    #     sudo('service mesos_master status')
    #   end
    # end

    desc 'Stop MesosMaster service'
    task :stop do
      # on roles(:mesos_master) do |host|
      #   # Ignore the exit(1) status when it's not running already
      #   sudo("#{mesos_master_home}/bin/mesos_master-server-stop.sh || true")
      # end
    end
  end
end

