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

        # Set /etc/zookeeper/conf/myid
        # The host name must end with a digit >= 0
        # Using `sed` to replace the generic text is a one-off change; it cannot
        # be updated automatically once the original text is replaced.  Once
        # the original text is replace, the sed becomes a no-op.  Note that
        # sed is used because an `echo $x >` incurs a file permission error.
        # This config file is heavily symlinked all over the place.
        i = host.to_s[-1].to_i
        raise 'ERROR: cannot update /etc/zookeeper/conf/myid' if i < 1 || i > 255
        sudo("sudo sed -i -e 's/replace.*/#{i}/' /etc/zookeeper/conf/myid")

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

        # TODO: Create a utility method that returns all the zookeeper details for /etc/hosts

        # TODO: Modify the zookeeper security group port settings
        # TODO: see ld4p-zoo-kafka_security_group.json
        # TODO: The zoo.cfg says:
        # # the port at which the clients will connect
        # clientPort=2181
        # # specify all zookeeper servers
        # # The fist port is used by followers to connect to the leader
        # # The second one is used for leader election
        # #server.1=zookeeper1:2888:3888
        # #server.2=zookeeper2:2888:3888
        # #server.3=zookeeper3:2888:3888


        # TODO: change the content in these files:
        sudo("cp #{current_path}/lib/zookeeper/zoo.cfg.#{stage} /etc/zookeeper/conf/zoo.cfg")

        # TODO: consider adding an additional data disk, the zoo.cfg says:
        # Place the dataLogDir to a separate physical disc for better performance
        # dataLogDir=/disk2/zookeeper



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

