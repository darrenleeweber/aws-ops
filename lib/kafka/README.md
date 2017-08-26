# Kafka

- http://kafka.apache.org/

See also:
- https://www.digitalocean.com/community/tutorials/how-to-install-apache-kafka-on-ubuntu-14-04
- https://github.com/voxpupuli/puppet-kafka

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
cap kafka:nodes:ssh_config_private                    # Compose private entries for ~/.ssh/config for nodes
cap kafka:nodes:ssh_config_public                     # Compose public entries for ~/.ssh/config for nodes
cap kafka:nodes:terminate                             # Terminate nodes
cap kafka:service:configure                           # Configure Kafka service
cap kafka:service:install                             # Install Kafka service
cap kafka:service:start                               # Start Kafka service
cap kafka:service:stop                                # Stop Kafka service
```

### Examples

```bash
```
