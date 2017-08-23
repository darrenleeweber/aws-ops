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

    desc 'Compose public entries for ~/.ssh/config for Zookeeper nodes'
    task :ssh_config_public do
      puts ZookeeperHelpers.ssh_config
    end

    desc 'Compose private entries for ~/.ssh/config for Zookeeper nodes'
    task :ssh_config_private do
      puts ZookeeperHelpers.ssh_config(false)
    end

    desc 'Compose entries for /etc/hosts using public IPs'
    task :etc_hosts_public do
      puts ZookeeperHelpers.etc_hosts.join("\n")
    end

    desc 'Compose entries for /etc/hosts using private IPs'
    task :etc_hosts_private do
      puts ZookeeperHelpers.etc_hosts(false).join("\n")
    end

    desc 'Compose entries for zoo.cfg'
    task :zoo_cfg do
      puts ZookeeperHelpers.zoo_cfg.join("\n")
    end

  end

  namespace :service do

    desc 'Upgrade Zookeeper service'
    task :debug do
      on roles(:zookeeper) do |host|
        puts host.hostname
        # require 'pry'
        # binding.pry
      end
    end

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

    # -----------------------------------
    # Configuration Notes
    #
    # - some of these notes require AWS changes, some are system/software changes.
    #
    # Try to assign IP addresses to each node and retain their network
    # interfaces whenever the instance is terminated and replaced.
    #
    # Try to retain the instance volume whenever it is terminated, so
    # the zookeeper data nodes are retained even when the instance is
    # replaced and added back into the quorum.
    #
    # TODO: consider adding an additional data disk, the zoo.cfg says:
    # Place the dataLogDir to a separate physical disc for better performance
    # dataLogDir=/disk2/zookeeper
    # -----------------------------------

    desc 'Configure Zookeeper service'
    task :configure do
      on roles(:zookeeper), in: :parallel do |host|
        # Disable RAM Swap on a zookeeper node
        sudo("#{current_path}/lib/zookeeper/zookeeper_disable_swap.sh")

        # Set /etc/zookeeper/conf/myid
        # The host name must end with a digit >= 0
        # Using `sed` to replace the generic text is a one-off change; it cannot
        # be updated automatically once the original text is replaced.  Once
        # the original text is replace, the sed becomes a no-op.  Note that
        # sed is used because an `echo $x >` incurs a file permission error.
        # This config file is heavily symlinked all over the place.
        myid = Settings.aws[host.hostname].myid
        raise 'ERROR: cannot update /etc/zookeeper/conf/myid' if myid < 1 || myid > 255
        sudo("sudo sed -i -e 's/replace.*/#{myid}/' /etc/zookeeper/conf/myid")

        # Setup the /etc/hosts file
        # Associate all the private IPs for each zookeeper instance with
        # their instance names on the {stage} cluster.  Consider additional
        # instance services also (Kafka, Mesos, etc.).  This will have to
        # be done automatically and updated whenever an instance is created
        # or terminated (unless their network interfaces are retained and
        # their IP address can be assigned).

        aws_ops_tag = 'ZOOKEEPER MANAGED BY AWS-OPS'
        aws_ops_comment = "\t# #{aws_ops_tag}\n"

        etc_hosts_new = ZookeeperHelpers.etc_hosts # use private here?
        etc_hosts_new = etc_hosts_new.join(aws_ops_comment) + aws_ops_comment
        # etc_hosts_old = capture('cat /etc/hosts') # should not need this, unless debugging
        # remove any existing zookeeper entries in the /etc/hosts file
        sudo("sudo sed -i -e '/#{aws_ops_tag}/d' /etc/hosts")
        # append new entries to the /etc/hosts file
        entry = "\n" + etc_hosts_new + "\n"
        sudo("echo #{entry} >> /etc/hosts")

        # Apply the template zoo.cfg file for the capistrano stage, note
        # that this template file is assumed to be deployed on the server already
        # and it could be a linked_file, if necessary.
        sudo("cp #{current_path}/lib/zookeeper/zoo.cfg.#{fetch(:stage)} /etc/zookeeper/conf/zoo.cfg")

        # Update the zookeeper server details in zoo.cfg, using /etc/hosts data
        zoo_cfg_new = ZookeeperHelpers.zoo_cfg
        zoo_cfg_new = zoo_cfg_new.join(aws_ops_comment) + aws_ops_comment
        # remove any existing zookeeper entries in the zoo.cfg file
        sudo("sudo sed -i -e '/#{aws_ops_tag}/d' /etc/zookeeper/conf/zoo.cfg")
        # append new entries to the zoo.cfg file
        entry = "\n" + zoo_cfg_new + "\n"
        sudo("echo #{entry} >> /etc/zookeeper/conf/zoo.cfg")
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

