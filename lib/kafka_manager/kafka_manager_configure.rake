require_relative 'kafka_manager_helpers'

# Kafka Manager Configuration
# https://github.com/yahoo/kafka-manager#configuration
#
namespace :kafka_manager do
  namespace :service do


    # /etc/default/kafka-manager defines:
    #
    #JAVA_OPTS="-Dpidfile.path=/var/run/kafka-manager.pid -Dconfig.file=/etc/kafka-manager/application.conf -Dlogger.file=/etc/kafka-manager/logger.xml $JAVA_OPTS"
    #PIDFILE="/var/run/kafka-manager.pid"

    ##########################################################################
    # BEGIN from https://github.com/yahoo/kafka-manager/issues/373

    # In /opt/kafka-manager-1.3.3.6/conf/application.ini
    #
    # -Dapplication.home=/opt/kafka-manager-1.3.3.6
    # -Dpidfile.path=/opt/kafka-manager-1.3.3.6/kafka-manager.pid
    # -Dhttp.port=8080

    # END from https://github.com/yahoo/kafka-manager/issues/373
    ##########################################################################



    def kafka_manager_application_conf
      # @kafka_manager_application_conf ||= capture('ls /usr/share/kafka-manager/conf/application.conf')
      @kafka_manager_application_conf ||= capture('ls /etc/kafka-manager/application.conf')
    end

    # basicAuthentication
    # basicAuthentication.enabled=false
    # basicAuthentication.username="admin"
    # basicAuthentication.password="password"
    # basicAuthentication.realm="Kafka-Manager"
    # basicAuthentication.excluded=["/api/health"] # ping the health of your instance without authentification
    def kafka_manager_authentication
      return unless KafkaManagerHelpers.configuration.basicAuthentication.enabled
      auth = KafkaManagerHelpers.configuration.basicAuthentication
      enabled = 'basicAuthentication.enabled=true'
      sudo("sed -i -e 's#basicAuthentication.enabled=.*##{enabled}#' #{kafka_manager_application_conf}")
      # basicAuthentication.username="admin"
      username = "basicAuthentication.username=\"#{auth.username}\""
      sudo("sed -i -e 's#basicAuthentication.username=.*##{username}#' #{kafka_manager_application_conf}")
      # basicAuthentication.password="password"
      password = "basicAuthentication.password=\"#{auth.password}\""
      sudo("sed -i -e 's#basicAuthentication.password=.*##{password}#' #{kafka_manager_application_conf}")
    end

    # application.features=["KMClusterManagerFeature","KMTopicManagerFeature",
    #                       "KMPreferredReplicaElectionFeature","KMReassignPartitionsFeature"]
    #
    # KMClusterManagerFeature - allows adding, updating, deleting cluster from Kafka Manager
    # KMTopicManagerFeature - allows adding, updating, deleting topic from a Kafka cluster
    # KMPreferredReplicaElectionFeature - allows running of preferred replica election for a Kafka cluster
    # KMReassignPartitionsFeature - allows generating partition assignments and reassigning partitions
    def kafka_manager_features
      features = "application.features=[#{KafkaManagerHelpers.configuration.features.join(',')}]"
      sudo("sed -i -e 's#application.features=.*##{features}#' #{kafka_manager_application_conf}")
    end

    # Set kafka-manager.zkhosts (note the /kafka chroot path)
    # - for multiple ZooKeeper instances, the kafka-manager.zkhosts should be a
    #   comma-separated string listing the IP addresses and port numbers
    #   of all the ZooKeeper instances.
    def kafka_manager_zookeeper_connect
      # kafka-manager.zkhosts="my-zookeeper-connection-string"
      # kafka-manager.base-zk-path="/a-chroot"  - don't see this in the installed file
      #
      # Note the use of a '#' in sed delimiter, because connections may contain `/` chars
      zk = ZookeeperHelpers.connections(false).join(',')
      zoo_connect = "kafka-manager.zkhosts=#{zk}/kafka"
      sudo("sed -i -e 's#kafka-manager.zkhosts=.*##{zoo_connect}#' #{kafka_manager_application_conf}")
    end

    desc 'Configure Kafka Manager'
    task :configure do
      on roles(:kafka_manager), in: :parallel do |host|
        kafka_manager_features
        kafka_manager_zookeeper_connect
      end
    end
  end
end

