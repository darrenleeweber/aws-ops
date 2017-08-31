require_relative 'kafka_helpers'

# Kafka Configuration
# https://kafka.apache.org/documentation/#brokerconfigs
#
# Developed using Kafka 0.11.x documentation
#
namespace :kafka do
  namespace :service do
    # Setup the /etc/hosts file for zookeeper nodes, using private IPs
    def update_etc_hosts
      zk_hosts = ZookeeperHelpers.manager.etc_hosts(false)
      # remove any existing server entries in /etc/hosts
      sudo("sed -i -e '/BEGIN_ZOO_SERVERS/,/END_ZOO_SERVERS/{ d; }' /etc/hosts")
      # append new entries to the /etc/hosts file (one line at a time)
      sudo("echo '### BEGIN_ZOO_SERVERS' | sudo tee -a /etc/hosts > /dev/null")
      zk_hosts.each do |etc_host|
        sudo("echo '#{etc_host}' | sudo tee -a /etc/hosts > /dev/null")
      end
      sudo("echo '### END_ZOO_SERVERS' | sudo tee -a /etc/hosts > /dev/null")
    end

    # ${KAFKA_HOME}/config/server.properties
    def kafka_server_properties
      @kafka_server_properties ||= capture("ls #{KafkaHelpers.kafka_home}/config/server.properties")
    end

    # Set broker.id
    # - the broker.id should be unique for each broker
    def kafka_broker_id
      broker_id = host_settings['broker_id']
      sudo("sed -i -e 's/broker.id=.*/broker.id=#{broker_id}/' #{kafka_server_properties}")
    end

    # Set zookeeper.connect (note the /kafka chroot path)
    # - the zookeeper.connect should be set to point to the same
    #   ZooKeeper instances
    # - for multiple ZooKeeper instances, the zookeeper.connect should be a
    #   comma-separated string listing the IP addresses and port numbers
    #   of all the ZooKeeper instances.
    def kafka_zookeeper_connect
      # Note the use of a '#' delimiter for sed here, because listener contains `/` chars
      zk = ZookeeperHelpers.connections.join(',')
      zoo_connect = "zookeeper.connect=#{zk}/kafka"
      sudo("sed -i -e 's#zookeeper.connect=.*##{zoo_connect}#' #{kafka_server_properties}")
    end

    # listeners - documentation is too sparse on this topic
    # https://cwiki.apache.org/confluence/display/KAFKA/Multiple+Listeners+for+Kafka+Brokers
    # https://stackoverflow.com/questions/42998859/kafka-server-configuration-listeners-vs-advertised-listeners
    #
    # KafkaConfig: we want to specify comma separated pairs of protocol, host and port, e.g.
    # ssl://192.1.1.8:9093, plaintext://10.1.1.5:9092
    #
    def kafka_listeners
      # On AWS, use the private IPs for internal access between the brokers
      # Note the use of a '#' delimiter for sed here, because listener contains `/` chars
      private_listener = KafkaHelpers.listeners[host.hostname]
      listeners = "listeners=#{private_listener}"
      sudo("sed -i -e 's/#listeners=/listeners=/' #{kafka_server_properties}") # remove '#' comment
      sudo("sed -i -e 's#listeners=.*##{listeners}#' #{kafka_server_properties}")
    end

    def kafka_advertised_listeners
      # On AWS, use the public IPs for external access to the brokers
      # Note the use of a '#' delimiter for sed here, because listener contains `/` chars
      public_listener = KafkaHelpers.advertised_listeners[host.hostname]
      advertised_listener = "advertised.listeners=#{public_listener}"
      sudo("sed -i -e 's/#advertised.listeners=/advertised.listeners=/' #{kafka_server_properties}")
      sudo("sed -i -e 's#advertised.listeners=.*##{advertised_listener}#' #{kafka_server_properties}")
    end

    desc 'Compose private listeners for brokers'
    task :listeners do
      params = KafkaHelpers.listeners
      puts JSON.pretty_generate(JSON.parse(params.to_json))
    end

    desc 'Compose public advertised.listeners for brokers'
    task :advertised_listeners do
      params = KafkaHelpers.advertised_listeners
      puts JSON.pretty_generate(JSON.parse(params.to_json))
    end

    # Modify the `server.properties` file in each broker
    desc 'Configure Kafka service'
    task :configure do
      on roles(:kafka), in: :parallel do |host|
        zookeeper_etc_hosts
        kafka_broker_id
        kafka_zookeeper_connect
        kafka_listeners
        kafka_advertised_listeners
      end
    end
  end
end

