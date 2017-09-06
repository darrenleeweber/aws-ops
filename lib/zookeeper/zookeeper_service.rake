require_relative 'zookeeper_helpers'

namespace :zookeeper do
  namespace :service do
    desc 'Restart service'
    task :restart do
      on roles(:zookeeper) do |host|
        sudo('service zookeeper restart')
      end
    end

    desc 'Start service'
    task :start do
      on roles(:zookeeper) do |host|
        sudo('service zookeeper start')
      end
    end

    desc 'Status of service'
    task :status do
      on roles(:zookeeper) do |host|
        sudo('service zookeeper status')
        execute("echo 'ruok' | nc localhost #{client_port}") # should respond 'imok'
      end
    end

    desc 'Stop service'
    task :stop do
      on roles(:zookeeper) do |host|
        sudo('service zookeeper stop')
      end
    end

    desc 'Zookeeper 4-letter commands'
    task :command, :cmd do |task, args|
      on roles(:zookeeper) do |host|
        execute("echo '#{args.cmd}' | nc localhost #{client_port}")
      end
    end
  end
end

