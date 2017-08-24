
# Utilities for working with config/settings/*.yml
class ServiceSettings

  attr_reader :service

  def initialize(service)
    @service = service
  end

  def service_keys
    Settings.aws.keys.select { |k| k.to_s.include? service }
  end

  def nodes
    keys = service_keys
    values = keys.map { |k| Settings.aws[k] }
    nodes = values.select { |v| v.resource == 'instance' }
    nodes.select { |n| n.tag_service == service }
  end

  def node_names
    nodes.map(&:tag_name)
  end

end

