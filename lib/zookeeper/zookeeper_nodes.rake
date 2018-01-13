require_relative 'zookeeper_helpers'

namespace :zookeeper do
  namespace :nodes do
    desc 'List settings in this project'
    task :check_settings do
      ZookeeperHelpers.settings.nodes.each do |params|
        puts JSON.pretty_generate(JSON.parse(params.to_json))
      end
    end

    desc 'Create nodes'
    task :create do
      ZookeeperHelpers.manager.create_nodes
    end

    desc 'Terminate nodes'
    task :terminate do
      ZookeeperHelpers.manager.terminate_nodes
    end

    desc 'Find and describe all nodes'
    task :find do
      puts ZookeeperHelpers.manager.describe_nodes
    end

    desc 'Compose public entries for ~/.ssh/config for nodes'
    task :ssh_config_public do
      puts ZookeeperHelpers.manager.ssh_config
    end

    desc 'Compose private entries for ~/.ssh/config for nodes'
    task :ssh_config_private do
      puts ZookeeperHelpers.manager.ssh_config(false)
    end

    desc 'Compose entries for /etc/hosts using public IPs'
    task :etc_hosts_public do
      puts ZookeeperHelpers.manager.etc_hosts.join("\n")
    end

    desc 'Compose entries for /etc/hosts using private IPs'
    task :etc_hosts_private do
      puts ZookeeperHelpers.manager.etc_hosts(false).join("\n")
    end
  end
end

