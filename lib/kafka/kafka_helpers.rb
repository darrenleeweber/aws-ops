
# Utilities for working with Kafka
module KafkaHelpers
  module_function

  SERVICE = 'kafka'.freeze

  def kafka_keys
    Settings.aws.keys.select { |k| k.to_s.include? 'kafka' }
  end

  def kafka_settings
    kafka_keys.map { |k| Settings.aws[k] }
  end

  def kafka_settings_names
    kafka_settings.map(&:tag_name)
  end

  def kafka_instances
    kafka_settings_names.map do |tag_name|
      AwsHelpers.ec2_find_name_instances(tag_name)
    end.flatten
  end

  def kafka_instance_names
    kafka_instances.map { |i| AwsHelpers.ec2_instance_tag_name(i) }
  end

  # Assumes the instance name is unique for instances that are not terminated
  def find_kafka_instance_by_name(name)
    instances = kafka_instances.select { |i| AwsHelpers.ec2_instance_tag_name?(i, name) }
    instances_alive = instances.reject { |i| i.state.name.to_s == 'terminated' }
    raise 'Found too many instances' if instances_alive.length > 1
    raise 'Not Found: #{name}' if instances_alive.empty?
    instances_alive.first
  end

  # Find and describe all Kafka nodes
  def describe_instances
    kafka_instances.each { |i| AwsHelpers.ec2_instance_info(i) }
  end

  # Create Kafka nodes
  def create_instances
    kafka_settings.each { |params| create_instance(params) }
  end

  # Create Kafka node
  # Attempts to be idempotent, but if details of settings change,
  # it cannot inspect everything to detect updates or instance replacements.
  # To replace instances and change their settings, terminate them and recreate them.
  def create_instance(params)
    # TODO: Can this task auto-update the config/deploy/{env} servers?
    i = find_kafka_instance_by_name(params.tag_name)
    if i.state.name.to_s == 'terminated'
      AwsHelpers.ec2_create params
    else
      puts "Found existing instance named: #{params.tag_name}"
    end
  rescue
    AwsHelpers.ec2_create params
  end

  # Terminate Kafka nodes
  # Requests confirmations for destructive actions
  def terminate_instances
    exit unless confirmation?('WARNING: terminating kafka can crash services')
    kafka_settings.each { |params| terminate_instance(params) }
  end

  # Terminate Kafka node
  # Attempts to be idempotent
  # Requests confirmations for destructive actions using `Capfile#confirmation?` (find a better pattern)
  def terminate_instance(params)
    # TODO: Can this task auto-update the config/deploy/{env} servers?
    i = find_kafka_instance_by_name(params.tag_name)
    return unless confirmation?("Terminate: #{params.tag_name}")
    AwsHelpers.ec2_terminate_instance(i.id)
  rescue
  end

end

