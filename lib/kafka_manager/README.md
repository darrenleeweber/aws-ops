# Kafka Manager

- https://github.com/yahoo/kafka-manager

## Configuration

- https://github.com/yahoo/kafka-manager#configuration

See `lib/kafka/kafka_manager_configure.rake`

Look for "kafka_manager" in:
 - `config/settings/{stage}.yml`
 - `config/deploy/{stage}.rb`

## Capistrano tasks

```bash
$ bundle exec cap -T | grep kafka_manager
```
