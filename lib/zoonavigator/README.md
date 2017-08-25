# ZooNavigator

- https://github.com/elkozmon/zoonavigator
- http://test_zookeeper1:8001
  - enter the zookeeper connection details
  - get the connection details from `cap {stage} zoonavigator:service:connections`
  - e.g. assuming the `/etc/hosts` are configured
    - test_zookeeper1:2181,test_zookeeper2:2181,test_zookeeper3:2181
  - there is no authorization in test

## Capistrano tasks

```bash
$ AWS_ENV=test bundle exec cap -T | grep zoonavigator
cap zoonavigator:service:connections                  # Zookeeper connections
cap zoonavigator:service:install                      # Install service
```
