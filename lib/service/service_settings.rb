
# Utilities for working with config/settings/*.yml
class ServiceSettings

  attr_reader :service

  def initialize(service)
    @service = service
  end

  def service_keys
    @service_keys ||= Settings.aws.keys.select { |k| k.to_s.include? service }
  end

  def service_values
    @service_values ||= service_keys.map { |k| Settings.aws[k] }
  end

  def configuration
    @configuration ||= service_values.select { |v| v.resource == 'configuration' }.first
  end

  def find_by_name(name)
    nodes.find { |n| n.tag_name == name }
  end

  def nodes
    @nodes ||= begin
      nodes = service_values.select { |v| v.resource == 'instance' }
      nodes.select { |n| n.tag_service == service }
    end
  end

  def node_names
    @node_names ||= nodes.map(&:tag_name)
  end

end

