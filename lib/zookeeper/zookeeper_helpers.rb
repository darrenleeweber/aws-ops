
# Utilities for working with Zookeeper
module ZookeeperHelpers
  module_function

  SERVICE = 'zookeeper'.freeze

  def zookeeper_keys
    Settings.aws.keys.select { |k| k.to_s.include? 'zookeeper' }
  end

  def zookeeper_settings
    zookeeper_keys.map { |k| Settings.aws[k] }
  end

  def zookeeper_settings_names
    zookeeper_settings.map(&:tag_name)
  end

  def zookeeper_instances
    zookeeper_settings_names.map do |tag_name|
      AwsHelpers.ec2_find_name_instances(tag_name)
    end.flatten
  end

  def zookeeper_instance_names
    zookeeper_instances.map { |i| AwsHelpers.ec2_instance_tag_name(i) }
  end

  # Assumes the instance name is unique for instances that are not terminated
  def find_zookeeper_instance_by_name(name)
    instances = zookeeper_instances.select { |i| AwsHelpers.ec2_instance_tag_name?(i, name) }
    instances_alive = instances.reject { |i| i.state.name.to_s == 'terminated' }
    raise 'Found too many instances' if instances_alive.length > 1
    raise 'Not Found: #{name}' if instances_alive.empty?
    instances_alive.first
  end

  # Find and describe all Zookeeper nodes
  def describe_instances
    zookeeper_instances.each { |i| AwsHelpers.ec2_instance_info(i) }
  end

  # Create Zookeeper nodes
  def create_instances
    zookeeper_settings.each { |params| create_instance(params) }
  end

  # Create Zookeeper node
  # Attempts to be idempotent, but if details of settings change,
  # it cannot inspect everything to detect updates or instance replacements.
  # To replace instances and change their settings, terminate them and recreate them.
  def create_instance(params)
    # TODO: Can this task auto-update the config/deploy/{env} servers?
    i = find_zookeeper_instance_by_name(params.tag_name)
    if i.state.name.to_s == 'terminated'
      AwsHelpers.ec2_create params
    else
      puts "Found existing instance named: #{params.tag_name}"
    end
  rescue
    AwsHelpers.ec2_create params
  end

  # Terminate Zookeeper nodes
  # Requests confirmations for destructive actions
  def terminate_instances
    exit unless confirmation?('WARNING: terminating zookeeper can crash services')
    zookeeper_settings.each { |params| terminate_instance(params) }
  end

  # Terminate Zookeeper node
  # Attempts to be idempotent
  # Requests confirmations for destructive actions using `Capfile#confirmation?` (find a better pattern)
  def terminate_instance(params)
    # TODO: Can this task auto-update the config/deploy/{env} servers?
    i = find_zookeeper_instance_by_name(params.tag_name)
    return unless confirmation?("Terminate: #{params.tag_name}")
    AwsHelpers.ec2_terminate_instance(i.id)
  rescue
  end

  # Install Zookeeper service
  def service_install
    # PuppetHelpers.puppet_apply('zookeeper.pp')
  end

  # Start Zookeeper service
  def service_start
    'service zookeeper restart'
  end

  # Status of Zookeeper service
  def service_status
    'service zookeeper status'
  end

  # Stop Zookeeper service
  def service_stop
    'service zookeeper stop'
  end

end

