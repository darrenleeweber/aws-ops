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

  end

  namespace :service do

    # desc 'Install Kafka service'
    # task :install do
    #   on roles(:kafka), in: :parallel do |host|
    #     # PuppetHelpers.puppet_apply('kafka.pp')
    #     sudo("#{current_path}/lib/bash/debian/java.sh")
    #     sudo("#{current_path}/lib/bash/debian/java8.sh")
    #     sudo("#{current_path}/lib/bash/debian/kafka.sh")
    #   end
    # end
    #
    # desc 'Upgrade Kafka service'
    # task :upgrade do
    #   on roles(:kafka), in: :parallel do |host|
    #     sudo('apt-get install -y -q --only-upgrade kafka')
    #   end
    # end
    #
    # desc 'Configure Kafka service'
    # task :configure do
    #   on roles(:kafka), in: :parallel do |host|
    #   end
    # end
    #
    # desc 'Start Kafka service'
    # task :start do
    #   on roles(:kafka) do |host|
    #     sudo('service kafka restart')
    #   end
    # end
    #
    # desc 'Status of Kafka service'
    # task :status do
    #   on roles(:kafka) do |host|
    #     sudo('service kafka status')
    #   end
    # end
    #
    # desc 'Stop Kafka service'
    # task :stop do
    #   on roles(:kafka) do |host|
    #     sudo('service kafka stop')
    #   end
    # end

  end

end

