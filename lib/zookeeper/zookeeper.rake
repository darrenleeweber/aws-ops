require_relative 'zookeeper_helpers'

namespace :zookeeper do

  namespace :nodes do

    desc 'List zookeeper settings in this project'
    task :check_settings do
      ZookeeperHelpers.zookeeper_settings.each { |params| puts params.to_json }
    end

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
        sudo("#{current_path}/lib/bash/debian/java.sh")
        sudo("#{current_path}/lib/bash/debian/java8.sh")
        sudo("#{current_path}/lib/bash/debian/zookeeper.sh")
      end
    end

    desc 'Upgrade Zookeeper service'
    task :upgrade do
      on roles(:zookeeper), in: :parallel do |host|
        sudo('apt-get install -y -q --only-upgrade zookeeper')
      end
    end

    desc 'Configure Zookeeper service'
    task :configure do
      on roles(:zookeeper), in: :parallel do |host|
        # TODO: the zookeeper instances must have a unique ID


        # Disable RAM Swap on a zookeeper node
        sudo("#{current_path}/lib/zookeeper/zookeeper_disable_swap.sh")

        # NOTES:
        # - some of these notes require AWS changes, some are system/software changes.

        # Try to assign IP addresses to each node and retain their network
        # interfaces whenever the instance is terminated and replaced.

        # Try to retain the instance volume whenever it is terminated, so
        # the zookeeper data nodes are retained even when the instance is
        # replaced and added back into the quorum.

        # Setup the /etc/hosts file
        # Associate all the private IPs for each zookeeper instance with
        # their instance names on the {stage} cluster.  Consider additional
        # instance services also (Kafka, Mesos, etc.).  This will have to
        # be done automatically and updated whenever an instance is created
        # or terminated (unless their network interfaces are retained and
        # their IP address can be assigned).

        # The host name must end with a digit >= 0
        i = host.to_s[-1].to_i
        raise 'ERROR: cannot update /etc/zookeeper/conf/myid' if i < 0
        sudo("echo #{i} > /etc/zookeeper/conf/myid")

        # TODO: change the content in these files:
        #execute('cat /etc/zookeeper/conf/zoo.cfg')

      end
    end

    desc 'Start Zookeeper service'
    task :start do
      on roles(:zookeeper) do |host|
        sudo('service zookeeper restart')
      end
    end

    desc 'Status of Zookeeper service'
    task :status do
      on roles(:zookeeper) do |host|
        sudo('service zookeeper status')
        execute("echo 'ruok' | nc localhost 2181 && echo") # should respond 'imok'
      end
    end

    desc 'Stop Zookeeper service'
    task :stop do
      on roles(:zookeeper) do |host|
        sudo('service zookeeper stop')
      end
    end

  end

end

