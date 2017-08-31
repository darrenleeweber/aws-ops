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

    desc 'Find and describe all nodes'
    task :find do
      KafkaHelpers.manager.describe_nodes
    end

    desc 'Reboot Kafka systems - WARNING, can reset IPs'
    task :reboot do
      KafkaHelpers.manager.reboot_nodes
    end

    desc 'Terminate nodes'
    task :terminate do
      KafkaHelpers.manager.terminate_nodes
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
end

