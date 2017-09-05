require_relative 'service_settings'

# Utilities for working with cluster nodes for a service
class ServiceManager

  attr_reader :service
  attr_reader :settings

  def initialize(service)
    @service = service
    @settings = ServiceSettings.new(service)
  end

  # All AWS::EC2::Instances for a service
  # @return [Array<Aws::EC2::Instance>]
  def nodes
    settings.node_names.map do |tag_name|
      AwsHelpers.ec2_find_name_instances(tag_name)
    end.flatten
  end

  # All AWS::EC2::Instances for a service that are "alive"
  # @return [Array<Aws::EC2::Instance>]
  def nodes_alive
    nodes.reject { |i| i.state.name.to_s == 'terminated' }
  end

  # All AWS::EC2::Instances for a service that are "running"
  # @return [Array<Aws::EC2::Instance>]
  def nodes_running
    nodes.reject { |i| i.state.name.to_s == 'running' }
  end

  # All AWS::EC2::Instances for a service that are "stopped"
  # @return [Array<Aws::EC2::Instance>]
  def nodes_stopped
    nodes.select { |i| i.state.name.to_s == 'stopped' }
  end

  # All AWS::EC2::Instances for a service that are "terminated"
  # - terminated instances are accessible for a short period
  # @return [Array<Aws::EC2::Instance>]
  def nodes_terminated
    nodes.select { |i| i.state.name.to_s == 'terminated' }
  end

  # The tag 'Name' of AWS::EC2::Instances in a service
  # @return [Array<String>]
  def node_names
    nodes.map { |i| AwsHelpers.ec2_instance_tag_name(i) }
  end

  # Assumes the node name is unique for nodes that are not terminated
  # @return [Aws::EC2::Instance]
  def find_node_by_name(name)
    nodes = nodes_alive.select { |i| AwsHelpers.ec2_instance_tag_name?(i, name) }
    raise 'Found too many nodes' if nodes.length > 1
    raise "Not Found: #{name}" if nodes.empty?
    nodes.first
  end

  # Find and describe all nodes
  # @return [nil] prints information
  def describe_nodes
    nodes.each { |i| AwsHelpers.ec2_instance_info(i) }
  end

  # Create /etc/hosts data
  def etc_hosts(public = true)
    alive = nodes_alive
    settings.nodes.map do |n|
      inst = alive.find { |i| AwsHelpers.ec2_instance_tag_name?(i, n.tag_name) }
      next if inst.nil?
      hosts = AwsHelpers.ec2_instance_etc_hosts(inst, public)
      hosts.sub!('{HOST}', n.tag_name)
    end
  end

  # Create entries for ~/.ssh/config
  def ssh_config(public = true)
    alive = nodes_alive
    settings.nodes.map do |n|
      inst = alive.find { |i| AwsHelpers.ec2_instance_tag_name?(i, n.tag_name) }
      next if inst.nil?
      hosts = AwsHelpers.ec2_instance_ssh_config(inst, public)
      hosts.sub!('{HOST}', n.tag_name)
      hosts.sub!('{USER}', n.user)
    end
  end

  # Create nodes
  def create_nodes
    alive = nodes_alive
    settings.nodes.each do |params|
      inst = alive.find { |i| AwsHelpers.ec2_instance_tag_name?(i, params.tag_name) }
      if inst.nil?
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
    inst = find_node_by_name(params.tag_name)
    if inst.nil?
      AwsHelpers.ec2_create params
    elsif inst.state.name.to_s == 'terminated'
      AwsHelpers.ec2_create params
    else
      puts "Found existing node named: #{params.tag_name}"
    end
  end

  # Reboot node
  def reboot_node(params)
    alive = nodes_alive
    inst = alive.find { |i| AwsHelpers.ec2_instance_tag_name?(i, params.tag_name) }
    return if inst.nil?
    puts "Rebooting active node named: #{params.tag_name}"
    AwsHelpers.ec2_reboot_instance(inst.id)
  end

  # Reboot nodes
  def reboot_nodes
    alive = nodes_alive
    settings.nodes.each do |params|
      inst = alive.find { |i| AwsHelpers.ec2_instance_tag_name?(i, params.tag_name) }
      next if inst.nil?
      puts "Rebooting active node named: #{params.tag_name}"
      AwsHelpers.ec2_reboot_instance(inst.id)
    end
  end

  # Stop node
  def stop_node(params)
    alive = nodes_alive
    inst = alive.find { |i| AwsHelpers.ec2_instance_tag_name?(i, params.tag_name) }
    return if inst.nil?
    puts "Stoping active node named: #{params.tag_name}"
    AwsHelpers.ec2_stop_instance(inst.id)
  end

  # Stop nodes
  def stop_nodes
    alive = nodes_alive
    settings.nodes.each do |params|
      inst = alive.find { |i| AwsHelpers.ec2_instance_tag_name?(i, params.tag_name) }
      next if inst.nil?
      puts "Stoping active node named: #{params.tag_name}"
      AwsHelpers.ec2_stop_instance(inst.id)
    end
  end

  # Terminate nodes
  # Requests confirmations for destructive actions
  def terminate_nodes
    return unless confirmation?("DANGER: terminating #{service} can impact other services")
    all = confirmation?("DANGER: terminate all #{service} nodes")
    alive = nodes_alive
    settings.nodes.each do |params|
      inst = alive.find { |i| AwsHelpers.ec2_instance_tag_name?(i, params.tag_name) }
      next if inst.nil?
      next unless all || confirmation?("DANGER: terminate #{params.tag_name}")
      AwsHelpers.ec2_terminate_instance(inst.id)
    end
  end

  # Terminate node
  # Attempts to be idempotent
  # Requests confirmations for destructive actions using `Capfile#confirmation?` (find a better pattern)
  def terminate_node(params)
    inst = find_node_by_name(params.tag_name)
    return if inst.nil?
    return unless confirmation?("Terminate: #{params.tag_name}")
    AwsHelpers.ec2_terminate_instance(inst.id)
  end

  private

  def confirmation?(msg)
    require 'highline/import'
    cli = HighLine.new
    confirm = cli.ask("#{msg}; do it? [y/n] ") { |yn| yn.limit = 1, yn.validate = /[yn]/i }
    confirm.downcase == 'y' # rubocop:disable Performance/Casecmp
  end

end

