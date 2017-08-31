require_relative 'kafka_helpers'

namespace :kafka do
  namespace :service do
    # Setup the capistrano default_env
    # - the kafka installation sets KAFKA_HOME and adds the
    #   KAFKA_HOME/bin to the PATH
    # - However, capistrano does not get these env values, see
    #   http://capistranorb.com/documentation/faq/why-does-something-work-in-my-ssh-session-but-not-in-capistrano/#
    def kafka_env
      default_env = fetch(:default_env)
      default_env['KAFKA_HOME'] = KafkaHelpers.kafka_home
      default_env['KAFKA_BIN']  = File.join(KafkaHelpers.kafka_home, 'bin')
      default_env['KAFKA_CONFIG'] = File.join(KafkaHelpers.kafka_home, 'config')
      default_env['KAFKA_HEAP_OPTS'] = KafkaHelpers.kafka_heap_opts
    end

    # desc 'Debug Kafka service'
    # task :debug do
    #   on roles(:kafka), in: :parallel do |host|
    #     #puts host.hostname + ' : ' + KafkaHelpers.advertised_listeners[host.hostname]
    #     kafka_env
    #     binding.pry
    #   end
    # end

    def kafka_running?
      jps = capture('sudo jps -l')
      jps.include? 'kafka.Kafka'
    end

    desc 'Start Kafka service'
    task :start do
      on roles(:kafka) do |host|
        kafka_env
        # TODO: Create 'kafka' user/group to run the service
        if kafka_running?
          puts "#{host.hostname} is already running Kafka"
        else
          opts = "KAFKA_HEAP_OPTS='#{KafkaHelpers.kafka_heap_opts}'"
          sudo("#{opts} ${KAFKA_BIN}/kafka-server-start.sh -daemon ${KAFKA_CONFIG}/server.properties")
        end
      end
    end

    desc 'Status of Kafka service'
    task :status do
      on roles(:kafka) do |host|
        if kafka_running?
          puts "#{host.hostname} is running Kafka"
        else
          puts "#{host.hostname} is not running Kafka"
        end
      end
    end

    desc 'Stop Kafka service'
    task :stop do
      on roles(:kafka) do
        kafka_env
        # Ignore the exit(1) status when it's not running already
        sudo('${KAFKA_BIN}/kafka-server-stop.sh || true')
      end
    end

    desc 'tail -n250 ${KAFKA_HOME}/logs/server.log'
    task :tail_server_log, :server do |_task, args|
      if args['server'].nil?
        puts "provide a single 'server' name"
        next
      end
      on roles(:kafka) do |host|
        next if host.hostname != args['server']
        kafka_env
        sudo('tail -n250 ${KAFKA_HOME}/logs/server.log')
      end
    end
  end
end

