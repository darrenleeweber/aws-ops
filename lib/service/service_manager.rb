require_relative 'service_settings'

# Utilities for working with cluster nodes for a service
class ServiceManager

  attr_reader :service
  attr_reader :settings

  def initialize(service)
    @service = service
    @settings = ServiceSettings.new(service)
    AwsHelpers.config
  end

  # All AWS::EC2::Instances for a service
  # @return [Array<Aws::EC2::Instance>]
  def nodes
    settings.node_names.map do |tag_name|
      AwsHelpers.ec2_find_name_instances(tag_name)
    end.flatten.compact
  end

  # All AWS::EC2::Instances for a service that are "alive"
  # @return [Array<Aws::EC2::Instance>]
  def nodes_alive
    nodes.reject { |i| i.state.name == 'terminated' }
  end

  # All AWS::EC2::Instances for a service that are "pending"
  # @return [Array<Aws::EC2::Instance>]
  def nodes_pending
    nodes.select { |i| i.state.name == 'pending' }
  end

  # All AWS::EC2::Instances for a service that are "running"
  # @return [Array<Aws::EC2::Instance>]
  def nodes_running
    nodes.select { |i| i.state.name == 'running' }
  end

  # All AWS::EC2::Instances for a service that are "shutting_down"
  # @return [Array<Aws::EC2::Instance>]
  def nodes_shutting_down
    nodes.select { |i| i.state.name == 'shutting-down' }
  end

  # All AWS::EC2::Instances for a service that are "stopped"
  # @return [Array<Aws::EC2::Instance>]
  def nodes_stopped
    nodes.select { |i| i.state.name == 'stopped' }
  end

  # All AWS::EC2::Instances for a service that are "stopping"
  # @return [Array<Aws::EC2::Instance>]
  def nodes_stopping
    nodes.select { |i| i.state.name == 'stopping' }
  end

  # All AWS::EC2::Instances for a service that are "terminated"
  # - terminated instances are accessible for a short period
  # @return [Array<Aws::EC2::Instance>]
  def nodes_terminated
    nodes.select { |i| i.state.name == 'terminated' }
  end

  # The tag 'Name' of AWS::EC2::Instances in a service
  # @return [Array<String>]
  def node_names
    nodes.map { |i| node_name(i) }
  end

  # The tag 'Name' of an AWS::EC2::Instance in a service
  # @return [String]
  def node_name(node)
    AwsHelpers.ec2_instance_tag_name(node)
  end

  # The Settings config for a node
  # @param node [AWS::EC2::Instance]
  # @return [Config::Options]
  def node_config(node)
    settings.find_by_name(node_name(node))
  end

  # Assumes the node name is unique for nodes that are not terminated
  # @return [Aws::EC2::Instance | nil]
  def find_node_by_name(name)
    nodes_alive.find { |i| AwsHelpers.ec2_instance_tag_name?(i, name) }
  end

  # Find and describe all nodes
  # @return [Array<String>] collects information
  def describe_nodes
    nodes.collect { |i| AwsHelpers.ec2_instance_describe(i) }
  end

  # Create /etc/hosts data
  # @param public [Boolean]
  def etc_hosts(public = true)
    nodes_alive.map do |inst|
      hosts = AwsHelpers.ec2_instance_etc_hosts(inst, public)
      hosts.sub!('{HOST}', node_name(inst))
    end
  end

  # Create entries for ~/.ssh/config
  def ssh_config(public = true)
    nodes_alive.map do |node|
      config = settings.find_by_name(node_name(node))
      hosts = AwsHelpers.ec2_instance_ssh_config(node, public)
      hosts.sub!('{HOST}', config.tag_name)
      hosts.sub!('{USER}', config.user)
    end
  end

  # Create node
  # Attempts to be idempotent, but if details of settings change,
  # it cannot inspect everything to detect updates or node replacements.
  # To replace nodes and change their settings, terminate them and recreate them.
  # @param config [Config::Options]
  def create_node(config)
    inst = find_node_by_name(config.tag_name)
    if inst.nil? || inst.state.name == 'terminated'
      AwsHelpers.ec2_create config
    else
      puts "Found existing node named: #{config.tag_name}"
    end
  end

  # Create nodes
  def create_nodes
    alive = nodes_alive
    settings.nodes.each do |config|
      inst = alive.find { |i| AwsHelpers.ec2_instance_tag_name?(i, config.tag_name) }
      if inst.nil?
        AwsHelpers.ec2_create config
      else
        puts "Found existing active node named: #{config.tag_name}"
      end
    end
  end

  # Reboot node
  # @param config [Config::Options]
  def reboot_node(config)
    inst = find_node_by_name(config.tag_name)
    return if inst.nil?
    puts "Rebooting active node named: #{config.tag_name}"
    AwsHelpers.ec2_reboot_instance(inst.id)
  end

  # Reboot nodes
  def reboot_nodes
    alive = nodes_alive
    settings.nodes.each do |config|
      inst = alive.find { |i| AwsHelpers.ec2_instance_tag_name?(i, config.tag_name) }
      next if inst.nil?
      puts "Rebooting active node named: #{config.tag_name}"
      AwsHelpers.ec2_reboot_instance(inst.id)
    end
  end

  # Stop node
  # @param config [Config::Options]
  def stop_node(config)
    inst = find_node_by_name(config.tag_name)
    return if inst.nil?
    puts "Stopping active node named: #{config.tag_name}"
    AwsHelpers.ec2_stop_instance(inst.id)
  end

  # Stop nodes
  def stop_nodes
    alive = nodes_alive
    settings.nodes.each do |config|
      inst = alive.find { |i| AwsHelpers.ec2_instance_tag_name?(i, config.tag_name) }
      next if inst.nil?
      puts "Stopping active node named: #{config.tag_name}"
      AwsHelpers.ec2_stop_instance(inst.id)
    end
  end

  # Terminate node
  # Requests confirmations for destructive actions
  # @param config [Config::Options]
  def terminate_node(config)
    inst = find_node_by_name(config.tag_name)
    if inst.nil?
      puts "Could not find #{config.tag_name} node"
    else
      return unless confirmation?("Terminate: #{node_status(inst)}")
      AwsHelpers.ec2_terminate_instance(inst.id)
    end
  end

  # Terminate nodes
  # Requests confirmations for destructive actions
  def terminate_nodes
    alive = nodes_alive
    if alive.empty?
      puts "There are no #{service} nodes alive"
    else
      return unless confirmation?("DANGER: terminating #{service} might impact other services")
      alive.each { |i| puts "Node alive: #{node_status(i)}" }
      all = confirmation?("DANGER: terminate all #{service} nodes")
      settings.nodes.each do |config|
        inst = alive.find { |i| AwsHelpers.ec2_instance_tag_name?(i, config.tag_name) }
        next if inst.nil?
        next unless all || confirmation?("DANGER: terminate #{node_status(inst)}")
        AwsHelpers.ec2_terminate_instance(inst.id)
      end
    end
  end

  private

  # @return [Boolean]
  def confirmation?(msg)
    require 'highline/import'
    cli = HighLine.new
    confirm = cli.ask("#{msg}; do it? [y/n] ") { |yn| yn.limit = 1, yn.validate = /[yn]/i }
    confirm.downcase == 'y' # rubocop:disable Performance/Casecmp
  end

  def node_status(inst)
    "#{AwsHelpers.ec2_instance_tag_name(inst)} (#{inst.id}, #{inst.state.name})"
  end

end

