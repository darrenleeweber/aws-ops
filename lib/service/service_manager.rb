require_relative 'service_settings'

# Utilities for working with cluster nodes for a service
class ServiceManager

  attr_reader :service
  attr_reader :settings

  def initialize(service)
    @service = service
    @settings = ServiceSettings.new(service)
  end

  def nodes
    settings.node_names.map do |tag_name|
      AwsHelpers.ec2_find_name_instances(tag_name)
    end.flatten
  end

  def nodes_alive
    nodes.reject { |i| i.state.name.to_s == 'terminated' }
  end

  # All AWS::EC2::Instances for a service that are "stopped"
  # @return [Array<Aws::EC2::Instance>]
  def nodes_stopped
    nodes.select { |i| i.state.name.to_s == 'stopped' }
  end

  def nodes_terminated
    nodes.select { |i| i.state.name.to_s == 'terminated' }
  end

  def node_names
    nodes.map { |i| AwsHelpers.ec2_instance_tag_name(i) }
  end

  # Assumes the node name is unique for nodes that are not terminated
  def find_node_by_name(name)
    nodes = nodes_alive.select { |i| AwsHelpers.ec2_instance_tag_name?(i, name) }
    raise 'Found too many nodes' if nodes.length > 1
    raise "Not Found: #{name}" if nodes.empty?
    nodes.first
  end

  # Find and describe all nodes
  def describe_nodes
    nodes.each { |i| AwsHelpers.ec2_instance_info(i) }
  end

  # Create /etc/hosts data
  def etc_hosts(public = true)
    alive = nodes_alive
    settings.nodes.map do |n|
      i = alive.find { |i| AwsHelpers.ec2_instance_tag_name?(i, n.tag_name) }
      next if i.nil?
      hosts = AwsHelpers.ec2_instance_etc_hosts(i, public)
      hosts.sub!('{HOST}', n.tag_name)
    end
  end

  # Create entries for ~/.ssh/config
  def ssh_config(public = true)
    alive = nodes_alive
    settings.nodes.map do |n|
      i = alive.find { |i| AwsHelpers.ec2_instance_tag_name?(i, n.tag_name) }
      next if i.nil?
      hosts = AwsHelpers.ec2_instance_ssh_config(i, public)
      hosts.sub!('{HOST}', n.tag_name)
      hosts.sub!('{USER}', n.user)
    end
  end

  # Create nodes
  def create_nodes
    alive = nodes_alive
    settings.nodes.each do |params|
      i = alive.find { |i| AwsHelpers.ec2_instance_tag_name?(i, params.tag_name) }
      if i.nil?
        AwsHelpers.ec2_create params
      else
        puts "Found existing active node named: #{params.tag_name}"
      end
    end
  end

  # Create node
  # Attempts to be idempotent, but if details of settings change,
  # it cannot inspect everything to detect updates or node replacements.
  # To replace nodes and change their settings, terminate them and recreate them.
  def create_node(params)
    i = find_node_by_name(params.tag_name)
    if i.nil?
      AwsHelpers.ec2_create params
    elsif i.state.name.to_s == 'terminated'
      AwsHelpers.ec2_create params
    else
      puts "Found existing node named: #{params.tag_name}"
    end
  end

  # Reboot node
  def reboot_node(params)
    alive = nodes_alive
    i = alive.find { |i| AwsHelpers.ec2_instance_tag_name?(i, params.tag_name) }
    return if i.nil?
    puts "Rebooting active node named: #{params.tag_name}"
    AwsHelpers.ec2_reboot_instance(i.id)
  end

  # Reboot nodes
  def reboot_nodes
    alive = nodes_alive
    settings.nodes.each do |params|
      i = alive.find { |i| AwsHelpers.ec2_instance_tag_name?(i, params.tag_name) }
      next if i.nil?
      puts "Rebooting active node named: #{params.tag_name}"
      AwsHelpers.ec2_reboot_instance(i.id)
    end
  end

  # Terminate nodes
  # Requests confirmations for destructive actions
  def terminate_nodes
    return unless confirmation?("DANGER: terminating #{service} can impact other services")
    all = confirmation?("DANGER: terminate all #{service} nodes")
    alive = nodes_alive
    settings.nodes.each do |params|
      i = alive.find { |i| AwsHelpers.ec2_instance_tag_name?(i, params.tag_name) }
      next if i.nil?
      next unless all || confirmation?("DANGER: terminate #{params.tag_name}")
      AwsHelpers.ec2_terminate_instance(i.id)
    end
  end

  # Terminate node
  # Attempts to be idempotent
  # Requests confirmations for destructive actions using `Capfile#confirmation?` (find a better pattern)
  def terminate_node(params)
    i = find_node_by_name(params.tag_name)
    return if i.nil?
    return unless confirmation?("Terminate: #{params.tag_name}")
    AwsHelpers.ec2_terminate_instance(i.id)
  end

end

