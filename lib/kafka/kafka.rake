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
        # The kafka_bin.sh script will set an env for KAFKA_HOME to /usr/local/kafka
        sudo("#{current_path}/lib/bash/debian/java_oracle_license.sh  > #{current_path}/log/bash_java_oracle_license.log")
        sudo("#{current_path}/lib/bash/debian/java_8_oracle.sh > #{current_path}/log/bash_java_8_oracle.log")
        sudo("#{current_path}/lib/bash/debian/kafka_bin.sh > #{current_path}/log/bash_kafka_bin.log")
      end
    end

    #
    # desc 'Configure Kafka service'
    # task :configure do
    #   on roles(:kafka), in: :parallel do |host|
    #   end
    # end

    desc 'Start Kafka service'
    task :start do
      on roles(:kafka) do |host|
        sudo('/usr/local/kafka/bin/kafka-server-start.sh -daemon /usr/local/kafka/config/server.properties')
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
        sudo('/usr/local/kafka/bin/kafka-server-stop.sh || true')
      end
    end

  end

end

