
# Utilities for working with Mesos
module MesosMasterHelpers

  module_function

  SERVICE = 'mesos_master'.freeze

  def settings
    @settings ||= ServiceSettings.new SERVICE
  end

  def manager
    @manager ||= ServiceManager.new SERVICE
  end

end

