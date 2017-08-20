
namespace :zookeeper do

  namespace :nodes do

    desc 'Create Zookeeper nodes'
    task :create do
      ZookeeperHelpers.create_instances
    end

    desc 'Terminate Zookeeper nodes'
    task :terminate do
      ZookeeperHelpers.terminate_instances
    end

    desc 'Find and describe all Zookeeper nodes'
    task :find do
      ZookeeperHelpers.describe_instances
    end

  end

  namespace :service do

    desc 'Install Zookeeper service'
    task :install do
      on roles(:zookeeper), in: :parallel do |host|
        # PuppetHelpers.puppet_apply('zookeeper.pp')
      end
    end

    desc 'Start Zookeeper service'
    task :start do
      on roles(:zookeeper), in: :parallel do |host|
        sudo('service zookeeper restart')
      end
    end

    desc 'Status of Zookeeper service'
    task :status do
      on roles(:zookeeper), in: :parallel do |host|
        sudo('service zookeeper status')
      end
    end

    desc 'Stop Zookeeper service'
    task :stop do
      on roles(:zookeeper), in: :parallel do |host|
        sudo('service zookeeper stop')
      end
    end

  end

end

