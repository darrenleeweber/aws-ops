# Zookeeper

- https://zookeeper.apache.org/doc/r3.4.8/index.html

See also:
- https://github.com/deric/puppet-zookeeper

## Configuration

See `lib/zookeeper/zoo.cfg.{stage}`

Look for "zookeeper" in:
 - `config/settings/{stage}.yml`
 - `config/deploy/{stage}.yml`

## Capistrano tasks

```bash
$ bundle exec cap -T | grep zookeeper
cap zookeeper:nodes:check_settings                    # List settings in this project
cap zookeeper:nodes:connections                       # Compose connection string
cap zookeeper:nodes:create                            # Create nodes
cap zookeeper:nodes:etc_hosts_private                 # Compose entries for /etc/hosts using private IPs
cap zookeeper:nodes:etc_hosts_public                  # Compose entries for /etc/hosts using public IPs
cap zookeeper:nodes:find                              # Find and describe all nodes
cap zookeeper:nodes:ssh_config_private                # Compose private entries for ~/.ssh/config for nodes
cap zookeeper:nodes:ssh_config_public                 # Compose public entries for ~/.ssh/config for nodes
cap zookeeper:nodes:terminate                         # Terminate nodes
cap zookeeper:nodes:zoo_cfg                           # Compose entries for zoo.cfg
cap zookeeper:service:command[cmd]                    # Zookeeper 4-letter commands
cap zookeeper:service:configure                       # Configure service
cap zookeeper:service:install                         # Install service
cap zookeeper:service:start                           # Start service
cap zookeeper:service:status                          # Status of service
cap zookeeper:service:stop                            # Stop service
cap zookeeper:service:upgrade                         # Upgrade service
```

### Examples

```bash
$ AWS_ENV=test bundle exec cap test zookeeper:service:command['ruok']
00:00 zookeeper:service:command
      01 echo 'ruok' | nc localhost 2181
      01 imok
    ✔ 01 ubuntu@test_zookeeper3 0.670s
      01 imok
    ✔ 01 ubuntu@test_zookeeper2 0.677s
      01 imok
    ✔ 01 ubuntu@test_zookeeper1 0.796s

$ AWS_ENV=test bundle exec cap test zookeeper:service:command['srvr']
00:00 zookeeper:service:command
      01 echo 'srvr' | nc localhost 2181
      01 Zookeeper version: 3.4.8-1--1, built on Fri, 26 Feb 2016 14:51:43 +0100
      01 Latency min/avg/max: 0/4/55
      01 Received: 43
      01 Sent: 42
      01 Connections: 1
      01 Outstanding: 0
      01 Zxid: 0x100000018
      01 Mode: follower
      01 Node count: 4
    ✔ 01 ubuntu@test_zookeeper1 0.674s
      01 Zookeeper version: 3.4.8-1--1, built on Fri, 26 Feb 2016 14:51:43 +0100
      01 Latency min/avg/max: 0/2/15
      01 Received: 33
      01 Sent: 32
      01 Connections: 1
      01 Outstanding: 0
      01 Zxid: 0x100000018
      01 Mode: follower
      01 Node count: 4
    ✔ 01 ubuntu@test_zookeeper2 0.689s
      01 Zookeeper version: 3.4.8-1--1, built on Fri, 26 Feb 2016 14:51:43 +0100
      01 Latency min/avg/max: 0/2/6
      01 Received: 26
      01 Sent: 25
      01 Connections: 1
      01 Outstanding: 0
      01 Zxid: 0x100000018
      01 Mode: leader
      01 Node count: 4
    ✔ 01 ubuntu@test_zookeeper3 0.696s

$ AWS_ENV=test bundle exec cap test zookeeper:nodes:etc_hosts_public
34.209.72.7	test_zookeeper1
34.213.183.106	test_zookeeper2
54.201.53.78	test_zookeeper3
```

## Zookeeper shell examples

```bash
# include zookeeper-shell examples
zookeeper-shell.sh localhost:2181
# display help
help
# display root
ls /
create /my-node "foo"
ls /
get /my-node
get /zookeeper
create /my-node/deeper-node "bar"
ls /
ls /my-node
ls /my-node/deeper-node
get /my-node/deeper-node
# update data version to see increased version counter
set /my-node/deeper-node "newdata"
get /my-node/deeper-node
# removes are recursive
rmr /my-node
ls /
# create a watcher
create /node-to-watch ""
get /node-to-watch true
set /node-to-watch "has-changed"
rmr /node-to-watch
```
