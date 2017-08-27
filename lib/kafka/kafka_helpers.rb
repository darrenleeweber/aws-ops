
# Utilities for working with Kafka
module KafkaHelpers

  module_function

  SERVICE = 'kafka'.freeze

  def settings
    @settings ||= ServiceSettings.new SERVICE
  end

  def manager
    @manager ||= ServiceManager.new SERVICE
  end

end

