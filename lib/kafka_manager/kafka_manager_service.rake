require_relative 'kafka_manager_helpers'

namespace :kafka_manager do
  namespace :service do
    desc 'Start Kafka Manager'
    task :start do
      on roles(:kafka_manager) do
        sudo('service kafka-manager start')
      end
    end

    desc 'Status of Kafka Manager'
    task :status do
      on roles(:kafka_manager) do
        execute('service kafka-manager status || true')
      end
    end

    desc 'Stop Kafka Manager'
    task :stop do
      on roles(:kafka_manager) do
        sudo('service kafka-manager stop')
      end
    end
  end
end

