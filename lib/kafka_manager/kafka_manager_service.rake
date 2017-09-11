require_relative 'kafka_manager_helpers'

namespace :kafka_manager do
  namespace :service do
    def kafka_manager_running?
      pid = capture('ls /usr/share/kafka-manager/RUNNING_PID')
      ! pid.nil?
    end

    desc 'Start Kafka Manager'
    task :start do
      on roles(:kafka_manager) do |host|
        # TODO: Create 'kafka' user/group to run the service
        if kafka_manager_running?
          puts "#{host.hostname} is already running Kafka Manager"
        else
          sudo('kafka-manager')
        end
      end
    end

    desc 'Status of Kafka Manager'
    task :status do
      on roles(:kafka_manager) do |host|
        if kafka_running?
          puts "#{host.hostname} is running Kafka Manager"
        else
          puts "#{host.hostname} is not running Kafka Manager"
        end
      end
    end

    desc 'Stop Kafka Manager'
    task :stop do
      on roles(:kafka_manager) do
        # Ignore the exit(1) status when it's not running already
        sudo('${KAFKA_BIN}/kafka-server-stop.sh || true')
      end
    end
  end
end

