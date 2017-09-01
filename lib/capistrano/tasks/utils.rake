# Capistrano task utility methods
# various capistrano variables should be accessible to these methods

def client_port
  host_settings['client_port']
end

def host_settings
  # the `host` object should be accessible to this method
  Settings.aws[host.hostname]
end

def install_java7
  sudo(ubuntu_helper.java_oracle_license)
  sudo(ubuntu_helper.java_7_oracle)
end

def install_java8
  sudo(ubuntu_helper.java_oracle_license)
  sudo(ubuntu_helper.java_8_oracle)
end

def ubuntu_helper
  # the `current_path` should be accessible to this method
  @ubuntu_helper ||= begin
    helper = UbuntuHelper.new(current_path)
    execute("mkdir -p #{helper.log_path}")
    helper
  end
end

