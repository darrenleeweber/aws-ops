# Kafka

- http://kafka.apache.org/

See also:
- https://www.digitalocean.com/community/tutorials/how-to-install-apache-kafka-on-ubuntu-14-04
- https://github.com/voxpupuli/puppet-kafka

Kafka on AWS
- https://docs.confluent.io/current/kafka/deployment.html#hardware
- https://www.confluent.io/blog/design-and-deployment-considerations-for-deploying-apache-kafka-on-aws/

"We recommend using d2.xlarge if you're using instance storage, or r3.xlarge or m4.2xlarge if you’re using EBS"


## Configuration

See `lib/kafka/kafka.rake :service:configure`

Look for "kafka" in:
 - `config/settings/{stage}.yml`
 - `config/deploy/{stage}.yml`

## Capistrano tasks

```bash
$ bundle exec cap -T | grep kafka
cap kafka:nodes:check_settings                        # List settings in this project
cap kafka:nodes:create                                # Create nodes
cap kafka:nodes:etc_hosts_private                     # Compose entries for /etc/hosts using private IPs
cap kafka:nodes:etc_hosts_public                      # Compose entries for /etc/hosts using public IPs
cap kafka:nodes:find                                  # Find and describe all nodes
cap kafka:nodes:reboot                                # Reboot Kafka systems - WARNING, can reset IPs
cap kafka:nodes:ssh_config_private                    # Compose private entries for ~/.ssh/config for nodes
cap kafka:nodes:ssh_config_public                     # Compose public entries for ~/.ssh/config for nodes
cap kafka:nodes:terminate                             # Terminate nodes
cap kafka:service:advertised_listeners                # Compose public advertised.listeners for brokers
cap kafka:service:brokers                             # Compose public brokers for client connections
cap kafka:service:brokers_private                     # Compose private brokers for client connections
cap kafka:service:configure                           # Configure Kafka service
cap kafka:service:install                             # Install Kafka service
cap kafka:service:listeners                           # Compose private listeners for brokers
cap kafka:service:start                               # Start Kafka service
cap kafka:service:status                              # Status of Kafka service
cap kafka:service:stop                                # Stop Kafka service
cap kafka:service:tail_server_log[server]             # tail -n250 ${KAFKA_HOME}/logs/server.log
```

### Using Kafka

```bash
export KAFKA_HOME=/opt/kafka

# get the zookeeper connection details (replace 'test' with your capistrano {stage})
ZK=$(AWS_ENV=test bundle exec cap test zookeeper:service:connections)
KAFKA_ZK="${ZK}/kafka"
echo $KAFKA_ZK

# list all the topics (should be zero for first installation)
${KAFKA_HOME}/bin/kafka-topics.sh --zookeeper ${KAFKA_ZK} --list

# create a 'test' topic
# - replication-factor must be less than or equal to the number of brokers
${KAFKA_HOME}/bin/kafka-topics.sh --zookeeper ${KAFKA_ZK} --create   --topic test --partitions 2 --replication-factor 1 --if-not-exists
${KAFKA_HOME}/bin/kafka-topics.sh --zookeeper ${KAFKA_ZK} --describe --topic test

# use console utils to observe pub/sub activity
# - use screen to create a vertical split window for the producer and consumer:
#   - `^A |` to split vertically and `^A tab` to jump between them
#   - `^A c` to create a new session in the right side window

# - in the left window:
# get the kafka broker list (replace 'test' with your capistrano {stage})
KAFKA_BROKERS=$(AWS_ENV=test bundle exec cap test kafka:service:brokers)
echo $KAFKA_BROKERS
# create the producer using:
${KAFKA_HOME}/bin/kafka-console-producer.sh --broker-list ${KAFKA_BROKERS} --topic test

# - in the right window:
# get the kafka broker list (replace 'test' with your capistrano {stage})
KAFKA_BROKERS=$(AWS_ENV=test bundle exec cap test kafka:service:brokers)
echo $KAFKA_BROKERS
# create the consumer using:
${KAFKA_HOME}/bin/kafka-console-consumer.sh --bootstrap-server ${KAFKA_BROKERS} --topic test

# - back in the left window, `^A |`, type in some one-line messages to the 'test' topic
# - watch the consumer in the right window echo back the messages
```
