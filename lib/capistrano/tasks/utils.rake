# Capistrano task utility methods
# various capistrano variables should be accessible to these methods

def client_port
  host_settings['client_port']
end

def host_settings
  # the `host` object should be accessible to this method
  Settings.aws[host.hostname]
end

def install_java_license
  sudo(ubuntu_helper.java_oracle_repository)
  sudo(ubuntu_helper.java_oracle_license)
end

def install_java7
  install_java_license
  sudo(ubuntu_helper.java_7_oracle)
end

def install_java8
  install_java_license
  sudo(ubuntu_helper.java_8_oracle)
end

def redhat_helper
  # the `current_path` should be accessible to this method
  # the `current_path` should exist only after a `cap {stage} deploy`
  @redhat_helper ||= begin
    validate_script_paths RedhatHelper.new(current_path)
  end
end

def ubuntu_helper
  # the `current_path` should be accessible to this method
  # the `current_path` should exist only after a `cap {stage} deploy`
  @ubuntu_helper ||= begin
    validate_script_paths UbuntuHelper.new(current_path)
  end
end

def validate_script_paths(helper)
  # validate that paths exist on the deployment systems
  execute("[ -d #{helper.current_path} ] || exit 1")
  execute("[ -d #{helper.log_path} ]     || exit 1")
  execute("[ -d #{helper.script_path} ]  || exit 1")
  helper
rescue StandardError
  puts "Run 'cap {stage} deploy' to ensure scripts and paths are available on remote hosts"
  raise 'Failure to deploy'
end

# @param json [String]
def pp_json(json)
  puts JSON.pretty_generate(JSON.parse(json))
end

# PRIVATE IPs for the /etc/hosts file with zookeeper nodes
# This utility method may be used by any services that depend on zookeeper.
# The PRIVATE IPs should persist when instances are stopped and restarted.
def zookeeper_etc_hosts
  zk_private_hosts = ZookeeperHelpers.manager.etc_hosts(false)
  # remove any existing server entries in /etc/hosts
  sudo("sed -i -e '/BEGIN_ZOO_SERVERS/,/END_ZOO_SERVERS/{ d; }' /etc/hosts")
  # append new entries to the /etc/hosts file (one line at a time)
  sudo("echo '### BEGIN_ZOO_SERVERS' | sudo tee -a /etc/hosts > /dev/null")
  zk_private_hosts.each do |etc_host|
    sudo("echo '#{etc_host}' | sudo tee -a /etc/hosts > /dev/null")
  end
  sudo("echo '### END_ZOO_SERVERS' | sudo tee -a /etc/hosts > /dev/null")
end

