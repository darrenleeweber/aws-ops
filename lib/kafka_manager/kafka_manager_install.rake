require_relative 'kafka_manager_helpers'

# Kafka Manager Installation
# https://github.com/yahoo/kafka-manager
#
namespace :kafka_manager do
  namespace :service do
    def install_kafka_manager
      install_java8
      # sudo(ubuntu_helper.sbt)
      sudo(ubuntu_helper.kafka_manager)
    end

    desc 'Install Kafka Manager service'
    task :install do
      on roles(:kafka_manager), in: :parallel do |host|
        install_kafka_manager
        KafkaManagerHelpers.manager.reboot_node(host_settings)
      end
    end
  end
end

