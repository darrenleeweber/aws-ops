require_relative 'mesos_agent_helpers'

namespace :mesos_agent do
  namespace :service do
    desc 'Start service'
    task :start do
      # on roles(:mesos_agent) do |host|
      #   # Does this command need to use an absolute path to use the default server.properties?
      #   sudo("#{mesos_agent_home}/bin/mesos_agent-server-start.sh -daemon #{mesos_agent_home}/config/server.properties")
      # end
    end

    # desc 'Status of service'
    # task :status do
    #   on roles(:mesos_agent) do |host|
    #     sudo('service mesos_agent status')
    #   end
    # end

    desc 'Stop service'
    task :stop do
      # on roles(:mesos_agent) do |host|
      #   # Ignore the exit(1) status when it's not running already
      #   sudo("#{mesos_agent_home}/bin/mesos_agent-server-stop.sh || true")
      # end
    end
  end
end

