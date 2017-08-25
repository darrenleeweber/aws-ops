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

    desc 'Install Kafka service'
    task :install do
      on roles(:kafka), in: :parallel do |host|
        # PuppetHelpers.puppet_apply('kafka.pp')
        host_settings = Settings.aws[host.hostname]
        kafka_home =  host_settings['kafka_home'] || '/opt/kafka'
        kafka_ver = [
          host_settings['scala_version']  || '2.11',
          host_settings['kafka_version '] || '0.11.0.0'
        ].join(' ')
        # Set or update the system ENV for KAFKA_HOME and the PATH
        # The kafka_bin.sh script should install into the KAFKA_HOME directory;
        # if 'KAFKA_HOME=/opt/kafka', then it should install
        # /opt/kafka sym-linked to /opt/kafka_{SCALA_VER}-{KAFKA-VER}
        sudo("sed -i -e'/export KAFKA_HOME/d' /etc/profile.d/kafka.sh > /dev/null 2>&1 || true")
        sudo("echo 'export KAFKA_HOME=#{kafka_home}' | sudo tee -a /etc/profile.d/kafka.sh")
        sudo("sed -i -e'/export PATH/d' /etc/profile.d/kafka.sh > /dev/null 2>&1 || true")
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
    # - the value of the broker.id property should be unique
    #   and different for each broker
    # - the value of the zookeeper.connect property should be
    #   changed such that all nodes point to the same ZooKeeper instance
    #
    # If you want to have multiple ZooKeeper instances for your cluster,
    # the value of the zookeeper.connect property on each node should be
    # an identical, comma-separated string listing the IP addresses and
    # port numbers of all the ZooKeeper instances.

    #
    # desc 'Configure Kafka service'
    # task :configure do
    #   on roles(:kafka), in: :parallel do |host|
    #     Replace the content in ${KAFKA_HOME}/config/server.properties
    #     sudo('kafka-server-start.sh -daemon ${KAFKA_HOME}/config/server.properties')
    #   end
    # end

    desc 'Start Kafka service'
    task :start do
      on roles(:kafka) do |host|
        # The installation adds the KAFKA_HOME/bin to the PATH
        # Does this command need to use an absolute path to use the default server.properties?
        sudo('kafka-server-start.sh -daemon ${KAFKA_HOME}/config/server.properties')
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
        # The installation adds the KAFKA_HOME/bin to the PATH
        # Ignore the exit(1) status when it's not running already
        sudo('kafka-server-stop.sh || true')
      end
    end

  end

end

