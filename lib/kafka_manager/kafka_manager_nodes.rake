require_relative 'kafka_manager_helpers'

namespace :kafka_manager do
  namespace :nodes do
    desc 'List settings in this project'
    task :check_settings do
      KafkaManagerHelpers.settings.nodes.each do |params|
        puts JSON.pretty_generate(JSON.parse(params.to_json))
      end
    end

    desc 'Create nodes'
    task :create do
      KafkaManagerHelpers.manager.create_nodes
    end

    desc 'Find and describe all nodes'
    task :find do
      KafkaManagerHelpers.manager.describe_nodes
    end

    desc 'Reboot Kafka systems - WARNING, can reset IPs'
    task :reboot do
      KafkaManagerHelpers.manager.reboot_nodes
    end

    desc 'Terminate nodes'
    task :terminate do
      KafkaManagerHelpers.manager.terminate_nodes
    end

    desc 'Compose public entries for ~/.ssh/config for nodes'
    task :ssh_config_public do
      puts KafkaManagerHelpers.manager.ssh_config
    end

    desc 'Compose entries for /etc/hosts using public IPs'
    task :etc_hosts_public do
      puts KafkaManagerHelpers.manager.etc_hosts.join("\n")
    end
  end
end

