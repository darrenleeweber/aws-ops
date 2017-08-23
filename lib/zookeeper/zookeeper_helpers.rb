require_relative 'zookeeper_settings'

# Utilities for working with Zookeeper
module ZookeeperHelpers
  module_function

  SERVICE = 'zookeeper'.freeze

  def zookeeper_instances
    ZookeeperSettings.settings_names.map do |tag_name|
      AwsHelpers.ec2_find_name_instances(tag_name)
    end.flatten
  end

  def instances_alive
    zookeeper_instances.reject { |i| i.state.name.to_s == 'terminated' }
  end

  def instances_terminated
    zookeeper_instances.select { |i| i.state.name.to_s == 'terminated' }
  end

  def instance_names
    zookeeper_instances.map { |i| AwsHelpers.ec2_instance_tag_name(i) }
  end

  # Assumes the instance name is unique for instances that are not terminated
  def find_instance_by_name(name)
    instances = instances_alive.select { |i| AwsHelpers.ec2_instance_tag_name?(i, name) }
    raise 'Found too many instances' if instances.length > 1
    raise "Not Found: #{name}" if instances.empty?
    instances.first
  end

  # Find and describe all nodes
  def describe_instances
    zookeeper_instances.each { |i| AwsHelpers.ec2_instance_info(i) }
  end

  # Create /etc/hosts data
  def etc_hosts(public = true)
    alive = instances_alive
    ZookeeperSettings.instance_settings.map do |zk|
      i = alive.find { |i| AwsHelpers.ec2_instance_tag_name?(i, zk.tag_name) }
      next if i.nil?
      hosts = AwsHelpers.ec2_instance_etc_hosts(i, public)
      hosts.sub!('{HOST}', zk.tag_name)
    end
  end

  # Create zoo.cfg data, something like:
  # server.1=zookeeper1:2888:3888
  # server.2=zookeeper2:2888:3888
  # server.3=zookeeper3:2888:3888
  #
  # leader_port - the first port is for connections to a leader
  # election_port - the second one is used for leader elections
  def zoo_cfg
    alive = instances_alive
    ZookeeperSettings.instance_settings.map do |zk|
      i = alive.find { |i| AwsHelpers.ec2_instance_tag_name?(i, zk.tag_name) }
      next if i.nil?
      "server.#{zk.myid}=#{zk.tag_name}:#{zk.leader_port}:#{zk.election_port}"
    end
  end

  # Create entries for ~/.ssh/config
  def ssh_config(public = true)
    alive = instances_alive
    ZookeeperSettings.instance_settings.map do |zk|
      i = alive.find { |i| AwsHelpers.ec2_instance_tag_name?(i, zk.tag_name) }
      next if i.nil?
      hosts = AwsHelpers.ec2_instance_ssh_config(i, public)
      hosts.sub!('{HOST}', zk.tag_name)
      hosts.sub!('{USER}', zk.user)
    end
  end

  # Create nodes
  def create_instances
    alive = instances_alive
    ZookeeperSettings.instance_settings.each do |params|
      i = alive.find { |i| AwsHelpers.ec2_instance_tag_name?(i, params.tag_name) }
      if i.nil?
        AwsHelpers.ec2_create params
      else
        puts "Found existing active instance named: #{params.tag_name}"
      end
    end
  end

  # Create node
  # Attempts to be idempotent, but if details of settings change,
  # it cannot inspect everything to detect updates or instance replacements.
  # To replace instances and change their settings, terminate them and recreate them.
  def create_instance(params)
    i = find_zookeeper_instance_by_name(params.tag_name)
    if i.nil?
      AwsHelpers.ec2_create params
    elsif i.state.name.to_s == 'terminated'
      AwsHelpers.ec2_create params
    else
      puts "Found existing instance named: #{params.tag_name}"
    end
  end

  # Terminate nodes
  # Requests confirmations for destructive actions
  def terminate_instances
    exit unless confirmation?('WARNING: terminating zookeeper can crash services')
    alive = instances_alive
    ZookeeperSettings.instance_settings.each do |params|
      i = alive.find { |i| AwsHelpers.ec2_instance_tag_name?(i, params.tag_name) }
      next if i.nil?
      return unless confirmation?("Terminate: #{params.tag_name}")
      AwsHelpers.ec2_terminate_instance(i.id)
    end
  end

  # Terminate node
  # Attempts to be idempotent
  # Requests confirmations for destructive actions using `Capfile#confirmation?` (find a better pattern)
  def terminate_instance(params)
    i = find_instance_by_name(params.tag_name)
    return if i.nil?
    return unless confirmation?("Terminate: #{params.tag_name}")
    AwsHelpers.ec2_terminate_instance(i.id)
  end

end

