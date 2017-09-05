
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
      configuration['scala_version'] || '2.11',
      configuration['kafka_version'] || '0.11.0.0'
    ].join(' ')
  end

  # listeners value, something like:
  # PLAINTEXT://your.host.name:9092
  #
  # KafkaHelpers.listeners
  # => {"test_kafka1"=>"PLAINTEXT://ec2-58-201-128-12.us-west-2.compute.amazonaws.com:9092",
  #     "test_kafka2"=>"PLAINTEXT://ec2-58-202-131-231.us-west-2.compute.amazonaws.com:9092",
  #     "test_kafka3"=>"PLAINTEXT://ec2-58-190-26-149.us-west-2.compute.amazonaws.com:9092"}
  def listeners
    alive = manager.nodes_alive
    settings.nodes.map do |n|
      inst = alive.find { |i| AwsHelpers.ec2_instance_tag_name?(i, n.tag_name) }
      next if inst.nil?
      [n.tag_name, "PLAINTEXT://#{inst.private_dns_name}:#{n.client_port}"]
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
    alive = manager.nodes_alive
    settings.nodes.map do |n|
      inst = alive.find { |i| AwsHelpers.ec2_instance_tag_name?(i, n.tag_name) }
      next if inst.nil?
      [n.tag_name, "PLAINTEXT://#{inst.public_dns_name}:#{n.client_port}"]
    end.to_h
  end

end

