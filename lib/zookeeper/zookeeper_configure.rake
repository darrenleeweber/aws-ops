require_relative 'zookeeper_helpers'

namespace :zookeeper do
  namespace :service do
    # Disable RAM Swap
    def zookeeper_disable_swap
      sudo("#{current_path}/lib/zookeeper/zookeeper_disable_swap.sh")
    end

    # Set /etc/zookeeper/conf/myid
    # The host name must end with a digit >= 0
    # Using `sed` to replace the generic text is a one-off change; it cannot
    # be updated automatically once the original text is replaced.  Once
    # the original text is replace, the sed becomes a no-op.  Note that
    # sed is used because an `echo $x >` incurs a file permission error.
    # This config file is heavily symlinked all over the place.
    def zookeeper_myid
      myid = Settings.aws[host.hostname].myid
      raise 'ERROR: cannot update /etc/zookeeper/conf/myid' if myid < 1 || myid > 255
      sudo("sed -i -e 's/replace.*/#{myid}/' /etc/zookeeper/conf/myid")
    end

    # Apply the template zoo.cfg file for the capistrano stage; note
    # that this template file is assumed to be deployed on the server already.
    def zoo_cfg_template
      sudo("cp #{current_path}/lib/zookeeper/zoo.cfg.#{fetch(:stage)} /etc/zookeeper/conf/zoo.cfg")
    end

    # Update the server details in zoo.cfg, using /etc/hosts data, to manage the
    # content within the BEGIN..END block, e.g.
    # ### BEGIN ZOO_SERVERS
    # server.1=zookeeper1:2888:3888
    # server.2=zookeeper2:2888:3888
    # server.3=zookeeper3:2888:3888
    # ### END ZOO_SERVERS
    def zoo_cfg
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

    desc 'Configure service'
    task :configure do
      on roles(:zookeeper), in: :parallel do |host|
        zookeeper_disable_swap
        zookeeper_myid
        zookeeper_etc_hosts
        zoo_cfg_template
        zoo_cfg
      end
    end

    desc 'Compose connection string'
    task :connections do
      puts ZookeeperHelpers.connections.join(',')
    end

    desc 'Compose entries for zoo.cfg'
    task :zoo_cfg do
      puts ZookeeperHelpers.zoo_cfg.join("\n")
    end
  end
end

