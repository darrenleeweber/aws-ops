require_relative 'kafka_helpers'

# Kafka Installation
# https://kafka.apache.org/documentation
#
# Developed using Kafka 0.11.x documentation
#
namespace :kafka do
  namespace :service do
    # Set or update the system ENV for KAFKA_HOME
    # The kafka_bin.sh script should install into the KAFKA_HOME directory;
    # if 'KAFKA_HOME=/opt/kafka', then it should install
    # /opt/kafka sym-linked to /opt/kafka_{SCALA_VER}-{KAFKA-VER}
    def update_kafka_home
      sudo("sed -i -e '/export KAFKA_HOME/d' /etc/profile.d/kafka.sh > /dev/null 2>&1 || true")
      sudo("echo 'export KAFKA_HOME=#{KafkaHelpers.kafka_home}' | sudo tee -a /etc/profile.d/kafka.sh")
    end

    # Set or update the system ENV for KAFKA_HEAP_OPTS
    def update_kafka_heap_opts
      sudo("sed -i -e '/export KAFKA_HEAP_OPTS/d' /etc/profile.d/kafka.sh > /dev/null 2>&1 || true")
      sudo("echo \"export KAFKA_HEAP_OPTS='#{KafkaHelpers.kafka_heap_opts}'\" | sudo tee -a /etc/profile.d/kafka.sh")
    end

    # Set or update the system PATH
    # The kafka_bin.sh script should install into the KAFKA_HOME directory;
    # if 'KAFKA_HOME=/opt/kafka', then add '$KAFKA_HOME/bin' to the PATH
    def update_kafka_path
      sudo("sed -i -e '/export PATH/d' /etc/profile.d/kafka.sh > /dev/null 2>&1 || true")
      sudo("echo 'export PATH=${PATH}:#{KafkaHelpers.kafka_home}/bin' | sudo tee -a /etc/profile.d/kafka.sh")
    end

    # Increase the file descriptor limits - allow 100,000 file descriptors
    def kafka_file_descriptors
      sudo("echo '* hard nofile 100000' | sudo tee    /etc/security/limits.d/kafka.conf")
      sudo("echo '* soft nofile 100000' | sudo tee -a /etc/security/limits.d/kafka.conf")
    end

    # Set the scala/kafka version to install and do it
    def install_kafka
      install_java8
      sudo(ubuntu_helper.kafka_bin(KafkaHelpers.kafka_ver))
    end

    desc 'Install Kafka service'
    task :install do
      on roles(:kafka), in: :parallel do |host|
        # PuppetHelpers.puppet_apply('kafka.pp')
        # TODO: Create 'kafka' user/group to run the service
        install_kafka
        update_kafka_home
        update_kafka_path
        update_kafka_heap_opts
        kafka_file_descriptors
        KafkaHelpers.manager.reboot_node(host_settings)
      end
    end
  end
end

