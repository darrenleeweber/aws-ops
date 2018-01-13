
# Utilities for working with Mesos
module MesosAgentHelpers

  module_function

  SERVICE = 'mesos_agent'.freeze

  def settings
    @settings ||= ServiceSettings.new SERVICE
  end

  def manager
    @manager ||= ServiceManager.new SERVICE
  end

end

