
# Utilities for working with Kafka
module KafkaManagerHelpers

  module_function

  SERVICE = 'kafka_manager'.freeze

  # KAFKA_HOME_DEFAULT = '/opt/kafka'.freeze

  def settings
    @settings ||= ServiceSettings.new SERVICE
  end

  def manager
    @manager ||= ServiceManager.new SERVICE
  end

  def configuration
    settings.configuration
  end

end

