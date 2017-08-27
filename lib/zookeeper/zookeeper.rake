require_relative 'zookeeper_helpers'

namespace :zookeeper do
  namespace :nodes do
    desc 'List settings in this project'
    task :check_settings do
      ZookeeperHelpers.settings.nodes.each do |params|
        puts JSON.pretty_generate(JSON.parse(params.to_json))
      end
    end

    desc 'Compose connection string'
    task :connections do
      puts ZookeeperHelpers.connections.join(',')
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
      ZookeeperHelpers.manager.describe_nodes
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

    desc 'Compose entries for zoo.cfg'
    task :zoo_cfg do
      puts ZookeeperHelpers.zoo_cfg.join("\n")
    end
  end

  namespace :service do
    def host_settings
      # the `host` object is accessible to this method
      Settings.aws[host.hostname]
    end

    def client_port
      host_settings['client_port']
    end

    desc 'Install service'
    task :install do
      on roles(:zookeeper), in: :parallel do |host|
        # PuppetHelpers.puppet_apply('zookeeper.pp')
        sudo("#{current_path}/lib/bash/debian/java_oracle_license.sh  > #{current_path}/log/bash_java_oracle_license.log")
        sudo("#{current_path}/lib/bash/debian/java_8_oracle.sh > #{current_path}/log/bash_java_8_oracle.log")
        sudo("#{current_path}/lib/bash/debian/zookeeper.sh > #{current_path}/log/bash_zookeeper.log")
      end
    end

    desc 'Upgrade service'
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

    desc 'Configure service'
    task :configure do
      on roles(:zookeeper), in: :parallel do |host|
        # Disable RAM Swap
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
        sudo("sed -i -e 's/replace.*/#{myid}/' /etc/zookeeper/conf/myid")

        # Setup the /etc/hosts file
        # Associate all the private IPs for each zookeeper instance with
        # their instance node_names on the {stage} cluster.  Consider additional
        # instance services also (Kafka, Mesos, etc.).  This will have to
        # be done automatically and updated whenever an instance is created
        # or terminated (unless their network interfaces are retained and
        # their IP address can be assigned).

        etc_hosts_new = ZookeeperHelpers.manager.etc_hosts(false) # use private IPs
        # remove any existing server entries in /etc/hosts
        sudo("sed -i -e '/BEGIN_ZOO_SERVERS/,/END_ZOO_SERVERS/{ d; }' /etc/hosts")
        # append new entries to the /etc/hosts file (one line at a time)
        sudo("echo '### BEGIN_ZOO_SERVERS' | sudo tee -a /etc/hosts > /dev/null")
        # append new entries to the /etc/hosts file (one line at a time)
        etc_hosts_new.each do |etc_host|
          sudo("echo '#{etc_host}' | sudo tee -a /etc/hosts > /dev/null")
        end
        sudo("echo '### END_ZOO_SERVERS' | sudo tee -a /etc/hosts > /dev/null")

        # Apply the template zoo.cfg file for the capistrano stage, note
        # that this template file is assumed to be deployed on the server already
        # and it could be a linked_file, if necessary.
        sudo("cp #{current_path}/lib/zookeeper/zoo.cfg.#{fetch(:stage)} /etc/zookeeper/conf/zoo.cfg")

        # Update the server details in zoo.cfg, using /etc/hosts data, to manage the
        # content within the BEGIN..END block, e.g.
        # ### BEGIN ZOO_SERVERS
        # server.1=zookeeper1:2888:3888
        # server.2=zookeeper2:2888:3888
        # server.3=zookeeper3:2888:3888
        # ### END ZOO_SERVERS
        zoo_cfg_new = ZookeeperHelpers.zoo_cfg
        # remove any existing server entries in the zoo.cfg file (see lib/zookeeper/zoo.cfg.test)
        sudo("sed -i -e '/BEGIN_ZOO_SERVERS/,/END_ZOO_SERVERS/{ d; }' /etc/zookeeper/conf/zoo.cfg")
        # append new entries to the zoo.cfg file (one line at a time)
        sudo("echo '### BEGIN_ZOO_SERVERS' | sudo tee -a /etc/zookeeper/conf/zoo.cfg > /dev/null")
        zoo_cfg_new.each do |server_cfg|
          sudo("echo '#{server_cfg}' | sudo tee -a /etc/zookeeper/conf/zoo.cfg > /dev/null")
        end
        sudo("echo '### END_ZOO_SERVERS' | sudo tee -a /etc/zookeeper/conf/zoo.cfg > /dev/null")

        # Reset the clientPort=2181 in zoo.cfg using the settings
        sudo("sed -i -e 's/clientPort=.*/clientPort=#{client_port}/' /etc/zookeeper/conf/zoo.cfg")
      end
    end

    desc 'Start service'
    task :start do
      on roles(:zookeeper) do |host|
        sudo('service zookeeper restart')
      end
    end

    desc 'Status of service'
    task :status do
      on roles(:zookeeper) do |host|
        sudo('service zookeeper status')
        execute("echo 'ruok' | nc localhost #{client_port}") # should respond 'imok'
      end
    end

    desc 'Stop service'
    task :stop do
      on roles(:zookeeper) do |host|
        sudo('service zookeeper stop')
      end
    end

    desc 'Zookeeper 4-letter commands'
    task :command, :cmd do |task, args|
      on roles(:zookeeper) do |host|
        execute("echo '#{args.cmd}' | nc localhost #{client_port}")
      end
    end
  end
end

