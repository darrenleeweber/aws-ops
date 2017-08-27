require_relative 'kafka_helpers'

namespace :kafka do
  namespace :nodes do
    desc 'List settings in this project'
    task :check_settings do
      KafkaHelpers.settings.nodes.each do |params|
        puts JSON.pretty_generate(JSON.parse(params.to_json))
      end
    end

    desc 'Create nodes'
    task :create do
      KafkaHelpers.manager.create_nodes
    end

    desc 'Terminate nodes'
    task :terminate do
      KafkaHelpers.manager.terminate_nodes
    end

    desc 'Find and describe all nodes'
    task :find do
      KafkaHelpers.manager.describe_nodes
    end

    desc 'Compose public entries for ~/.ssh/config for nodes'
    task :ssh_config_public do
      puts KafkaHelpers.manager.ssh_config
    end

    desc 'Compose private entries for ~/.ssh/config for nodes'
    task :ssh_config_private do
      puts KafkaHelpers.manager.ssh_config(false)
    end

    desc 'Compose entries for /etc/hosts using public IPs'
    task :etc_hosts_public do
      puts KafkaHelpers.manager.etc_hosts.join("\n")
    end

    desc 'Compose entries for /etc/hosts using private IPs'
    task :etc_hosts_private do
      puts KafkaHelpers.manager.etc_hosts(false).join("\n")
    end
  end

  namespace :service do
    # The kafka installation sets KAFKA_HOME and adds the
    # KAFKA_HOME/bin to the PATH
    # However, capistrano does not get these env values, see
    # http://capistranorb.com/documentation/faq/why-does-something-work-in-my-ssh-session-but-not-in-capistrano/#

    KAFKA_HOME_DEFAULT = '/opt/kafka'.freeze

    def host_settings
      # the `host` object is accessible to this method
      Settings.aws[host.hostname]
    end

    def kafka_home
      host_settings['kafka_home'] || KAFKA_HOME_DEFAULT
    end

    def kafka_ver
      settings = host_settings
      [
        settings['scala_version']  || '2.11',
        settings['kafka_version '] || '0.11.0.0'
      ].join(' ')
    end

    def zookeeper_connections
      ZookeeperHelpers.connections.join(',')
    end

    desc 'Install Kafka service'
    task :install do
      on roles(:kafka), in: :parallel do |host|
        # PuppetHelpers.puppet_apply('kafka.pp')
        # Set or update the system ENV for KAFKA_HOME and the PATH
        # The kafka_bin.sh script should install into the KAFKA_HOME directory;
        # if 'KAFKA_HOME=/opt/kafka', then it should install
        # /opt/kafka sym-linked to /opt/kafka_{SCALA_VER}-{KAFKA-VER}
        sudo("sed -i -e '/export KAFKA_HOME/d' /etc/profile.d/kafka.sh > /dev/null 2>&1 || true")
        sudo("echo 'export KAFKA_HOME=#{kafka_home}' | sudo tee -a /etc/profile.d/kafka.sh")
        sudo("sed -i -e '/export PATH/d' /etc/profile.d/kafka.sh > /dev/null 2>&1 || true")
        sudo("echo 'export PATH=${PATH}:#{kafka_home}/bin' | sudo tee -a /etc/profile.d/kafka.sh")
        # Set the scala/kafka version to install and do it, check dependencies
        sudo("#{current_path}/lib/bash/debian/java_oracle_license.sh  > #{current_path}/log/bash_java_oracle_license.log")
        sudo("#{current_path}/lib/bash/debian/java_8_oracle.sh > #{current_path}/log/bash_java_8_oracle.log")
        sudo("#{current_path}/lib/bash/debian/kafka_bin.sh #{kafka_ver} > #{current_path}/log/bash_kafka_bin.log")
      end
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

    desc 'Configure Kafka service'
    task :configure do
      on roles(:kafka), in: :parallel do |host|
        # Replace the content in ${KAFKA_HOME}/config/server.properties
        config_file = capture("ls #{kafka_home}/config/server.properties")

        # Set broker.id
        broker_id = host_settings['broker_id']
        sudo("sed -i -e 's/broker.id=.*/broker.id=#{broker_id}/' #{config_file}")

        # Set zookeeper.connect
        zoo_connect = "zookeeper.connect=#{zookeeper_connections}"
        sudo("sed -i -e 's/zookeeper.connect=.*/#{zoo_connect}/' #{config_file}")

        # Setup the /etc/hosts file for zookeeper nodes, using private IPs
        etc_hosts_new = ZookeeperHelpers.manager.etc_hosts(false) # use private IPs
        # remove any existing server entries in /etc/hosts
        sudo("sed -i -e '/BEGIN_ZOO_SERVERS/,/END_ZOO_SERVERS/{ d; }' /etc/hosts")
        # append new entries to the /etc/hosts file (one line at a time)
        sudo("echo '### BEGIN_ZOO_SERVERS' | sudo tee -a /etc/hosts > /dev/null")
        # append new entries to the /etc/hosts file (one line at a time)
        etc_hosts_new.each do |etc_host|
          sudo("echo '#{etc_host}' | sudo tee -a /etc/hosts > /dev/null")
        end
        sudo("echo '### END_ZOO_SERVERS' | sudo tee -a /etc/hosts > /dev/null")

        # TODO: advertised.listeners=PLAINTEXT://your.host.name:9092
      end
    end

    desc 'Start Kafka service'
    task :start do
      on roles(:kafka) do |host|
        # Does this command need to use an absolute path to use the default server.properties?
        sudo("#{kafka_home}/bin/kafka-server-start.sh -daemon #{kafka_home}/config/server.properties")
      end
    end

    # desc 'Status of Kafka service'
    # task :status do
    #   on roles(:kafka) do |host|
    #     sudo('service kafka status')
    #   end
    # end

    desc 'Stop Kafka service'
    task :stop do
      on roles(:kafka) do |host|
        # Ignore the exit(1) status when it's not running already
        sudo("#{kafka_home}/bin/kafka-server-stop.sh || true")
      end
    end
  end
end

