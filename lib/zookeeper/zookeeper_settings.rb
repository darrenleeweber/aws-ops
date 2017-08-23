
# Utilities for working with config/settings/*.yml
module ZookeeperSettings
  module_function

  SERVICE = 'zookeeper'.freeze

  def zookeeper_keys
    Settings.aws.keys.select { |k| k.to_s.include? SERVICE }
  end

  def instance_settings
    instance_keys = zookeeper_keys.select do |k|
      v = Settings.aws[k]
      v.resource == 'instance' && v.tag_service == SERVICE
    end
    instance_keys.map { |k| Settings.aws[k] }
  end

  def settings_names
    instance_settings.map(&:tag_name)
  end

end

