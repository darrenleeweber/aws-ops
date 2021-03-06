
# Utilities for working with Kafka
module KafkaHelpers

  module_function

  SERVICE = 'kafka'.freeze

  KAFKA_HOME_DEFAULT = '/opt/kafka'.freeze

  KAFKA_HEAP_OPTS = '-Xmx1G -Xms1G'.freeze

  def settings
    @settings ||= ServiceSettings.new SERVICE
  end

  def manager
    @manager ||= ServiceManager.new SERVICE
  end

  def configuration
    settings.configuration
  end

  def kafka_home
    @kafka_home ||= configuration['kafka_home'] || KAFKA_HOME_DEFAULT
  end

  def kafka_heap_opts
    @kafka_heap_opts ||= configuration['kafka_heap_opts'] || KAFKA_HEAP_OPTS
  end

  def kafka_ver
    @kafka_ver ||= [
      configuration['scala_version'] || '2.12',
      configuration['kafka_version'] || '1.0.0'
    ].join(' ')
  end

  # broker list, something like:
  # ec2-58-213-10-149.us-west-2.compute.amazonaws.com:9092,etc.
  # @param public [Boolean]
  # @return [String]
  def brokers(public = true)
    manager.nodes_running.map do |inst|
      node = settings.nodes.find { |n| n.tag_name == manager.node_name(inst) }
      dns = public ? inst.public_dns_name : inst.private_dns_name
      "#{dns}:#{node.client_port}"
    end.join(',')
  end

  # listeners value, something like:
  # PLAINTEXT://your.host.name:9092
  #
  # KafkaHelpers.listeners
  # => {"test_kafka1"=>"PLAINTEXT://ec2-58-201-128-12.us-west-2.compute.amazonaws.com:9092",
  #     "test_kafka2"=>"PLAINTEXT://ec2-58-202-131-231.us-west-2.compute.amazonaws.com:9092",
  #     "test_kafka3"=>"PLAINTEXT://ec2-58-190-26-149.us-west-2.compute.amazonaws.com:9092"}
  def listeners
    manager.nodes_running.map do |inst|
      node = settings.nodes.find { |n| n.tag_name == manager.node_name(inst) }
      [node.tag_name, "PLAINTEXT://#{inst.private_dns_name}:#{node.client_port}"]
    end.to_h
  end

  # advertised.listeners value, something like:
  # PLAINTEXT://your.host.name:9092
  #
  # KafkaHelpers.advertised_listeners
  # => {"test_kafka1"=>"PLAINTEXT://ec2-58-201-128-12.us-west-2.compute.amazonaws.com:9092",
  #     "test_kafka2"=>"PLAINTEXT://ec2-58-202-131-231.us-west-2.compute.amazonaws.com:9092",
  #     "test_kafka3"=>"PLAINTEXT://ec2-58-190-26-149.us-west-2.compute.amazonaws.com:9092"}
  def advertised_listeners
    manager.nodes_running.map do |inst|
      node = settings.nodes.find { |n| n.tag_name == manager.node_name(inst) }
      [node.tag_name, "PLAINTEXT://#{inst.public_dns_name}:#{node.client_port}"]
    end.to_h
  end

end

