require_relative 'kafka_helpers'

namespace :kafka do

  namespace :nodes do

    desc 'List kafka settings in this project'
    task :check_settings do
      KafkaHelpers.kafka_settings.each { |params| puts params.to_json }
    end

    desc 'Create Kafka nodes'
    task :create do
      KafkaHelpers.create_instances
    end

    desc 'Terminate Kafka nodes'
    task :terminate do
      KafkaHelpers.terminate_instances
    end

    desc 'Find and describe all Kafka nodes'
    task :find do
      KafkaHelpers.describe_instances
    end

    desc 'Compose entries for ~/.ssh/config for Kafka nodes'
    task :ssh_config do
      KafkaHelpers.ssh_config
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

