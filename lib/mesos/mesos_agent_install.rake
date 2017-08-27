require_relative 'mesos_agent_helpers'

namespace :mesos_agent do
  namespace :service do
    MESOS_HOME_DEFAULT = '/opt/mesos_agent'.freeze

    def mesos_agent_home
      host_settings['mesos_agent_home'] || MESOS_HOME_DEFAULT
    end

    def mesos_agent_ver
      settings = host_settings
      [
        settings['scala_version'] || '2.11',
        settings['mesos_agent_version '] || '0.11.0.0'
      ].join(' ')
    end

    def zookeeper_connections
      ZookeeperHelpers.connections.join(',')
    end

    desc 'Install service'
    task :install do
      # on roles(:mesos_agent), in: :parallel do |host|
      #   # PuppetHelpers.puppet_apply('mesos_agent.pp')
      #   # Set or update the system ENV for MESOS_HOME and the PATH
      #   # The mesos_agent_bin.sh script should install into the MESOS_HOME directory;
      #   # if 'MESOS_HOME=/opt/mesos_agent', then it should install
      #   # /opt/mesos_agent sym-linked to /opt/mesos_agent_{SCALA_VER}-{MESOS-VER}
      #   sudo("sed -i -e '/export MESOS_HOME/d' /etc/profile.d/mesos_agent.sh > /dev/null 2>&1 || true")
      #   sudo("echo 'export MESOS_HOME=#{mesos_agent_home}' | sudo tee -a /etc/profile.d/mesos_agent.sh")
      #   sudo("sed -i -e '/export PATH/d' /etc/profile.d/mesos_agent.sh > /dev/null 2>&1 || true")
      #   sudo("echo 'export PATH=${PATH}:#{mesos_agent_home}/bin' | sudo tee -a /etc/profile.d/mesos_agent.sh")
      #   # Set the scala/mesos_agent version to install and do it, check dependencies
      #   sudo("#{current_path}/lib/bash/debian/java_oracle_license.sh  > #{current_path}/log/bash_java_oracle_license.log")
      #   sudo("#{current_path}/lib/bash/debian/java_8_oracle.sh > #{current_path}/log/bash_java_8_oracle.log")
      #   sudo("#{current_path}/lib/bash/debian/mesos_agent_bin.sh #{mesos_agent_ver} > #{current_path}/log/bash_mesos_agent_bin.log")
      # end
    end
  end
end

