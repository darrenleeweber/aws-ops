
[![Build Status](https://travis-ci.org/darrenleeweber/aws-ops.svg?branch=master)](https://travis-ci.org/darrenleeweber/aws-ops)  [![Maintainability](https://api.codeclimate.com/v1/badges/3cf2ea6b174c68dce41f/maintainability)](https://codeclimate.com/github/darrenleeweber/aws-ops/maintainability)  [![Test Coverage](https://api.codeclimate.com/v1/badges/3cf2ea6b174c68dce41f/test_coverage)](https://codeclimate.com/github/darrenleeweber/aws-ops/test_coverage)  [![Coverage Status](https://coveralls.io/repos/github/darrenleeweber/aws-ops/badge.svg?branch=master)](https://coveralls.io/github/darrenleeweber/aws-ops?branch=master)

# aws-ops
Utils to provision services on AWS

Incomplete - work in progress.

# Goals
 - use ruby AWS API client to provision AWS resources
 - use capistrano for service installation/configuration
 - use bash scripts and/or puppet provision tools
 - use convenient capistrano/rake tasks
 - manage settings with the config gem
    - default settings are in config/settings/test.yml
 - use AWS discovery services to find everything dynamically

# Background information and resources
 - https://aws.amazon.com/blogs/devops/tag/capistrano/
 - http://fuzzyblog.io/blog/aws/2016/09/23/aws-tutorial-09-deploying-rails-apps-to-aws-with-capistrano-take-1.html

# Install
```bash
git clone https://github.com/darrenleeweber/aws-ops.git
cd aws-ops
bundle install
bundle exec cap -T
```

# Configure

### AWS Access Keys

Use the AWS console to create any authorized user/group accounts for access
to any or all of the AWS services.  For a user, get their access-key-id and
the security-access-key.  Details can be found at AWS documentation, e.g.
- http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html

Use the `aws configure --profile <username>` to set these access credentials for
the AWS CLI utility.  It saves the values to `~/.aws/credentials`.

I also like to set environment variables, e.g.

```bash
export AWS_SECRET_ACCESS_KEY=<YourKey>
export AWS_ACCESS_KEY_ID=<YourKeyID>
export AWS_DEFAULT_REGION=<YourRegion>
```

### AWS Key Pairs

Use the AWS console to create and save any Key Pairs to be used for access
to any or all of the AWS EC2 instances.  Add the name of a key pair to the
`/config/settings/{stage}.rb` instances.

```bash
# Setup your AWS credentials using ENV values or config/setting.yml
bundle exec cap dev ops:aws:check_credentials
```

Once any instance is created and assigned a public DNS, it can be added to
your `/etc/hosts` file and a corresponding entry in `~/.ssh/config` file,
along with the required AWS Key Pair used to access it.  It's recommended
that a `Host` value matches the instance name in `config/settings/{stage}.yml`
and it's essential that the `Host` value is used in the Capistrano stage file
to define a "server" entry by that name (e.g. `config/deploy/{stage}.rb` settings).
(Note that it is easier to use the same `CLUSTER_SETTINGS` or `CLUSTER_ENV` name
as the capistrano `{stage}` name, but this is not essential, they can be different.)

An example of an `/etc/hosts/` and matching `~/.ssh/config` entry:
```
# /etc/hosts entry
{AWS_PUBLIC_IP} {AWS_PUBLIC_DNS} {YourHostAlias}

# ~/.ssh/config entry
Host <Instance name in your config/settings/{stage}.yml>
  Hostname {YourHostAlias}
  user {ubuntu or something}
  IdentityFile ~/.ssh/{AWS_Key_Pair_Name}.pem
  Port 22
```

To test the ssh access to any AWS EC2 public DNS, try something like:
```bash
ssh -i ~/.ssh/{AWS_Key_Pair_Name}.pem {user}@{AWS_PUBLIC_DNS}
```

If that works and the `/etc/hosts` and `~/.ssh/config` entries exist, try:
```bash
ssh {YourHostAlias}
```

There are some capistrano tasks to provide details for the `~/.ssh/config` and
related `/etc/hosts` values, e.g.
```bash
cap zookeeper:nodes:find                 # Find and describe all nodes
cap zookeeper:nodes:etc_hosts_private    # Compose entries for /etc/hosts using private IPs
cap zookeeper:nodes:etc_hosts_public     # Compose entries for /etc/hosts using public IPs
cap zookeeper:nodes:ssh_config_private   # Compose private entries for ~/.ssh/config for nodes
cap zookeeper:nodes:ssh_config_public    # Compose public entries for ~/.ssh/config for nodes
```

WARNING: the `/etc/hosts` entries must be updated whenever an instance is
stopped and restarted, because the public network interface can change.  Also, there might be
problems with the `~/.ssh/known_hosts` file when a system is restarted and assigned a new
host fingerprint.

### AWS Switching Accounts

- reset the AWS environment variables with access credentials
```bash
AWS_DEFAULT_REGION={region}
AWS_SECRET_ACCESS_KEY={key}
AWS_ACCESS_KEY_ID={id}
```
- update the `config/settings/{stage}.yml`
  - update the instance default details for the `{key-name}.pem`, i.e.
    - `key_name: {key-name}`
  - update the VPC settings for security groups, i.e.
    - `vpc_id: {vpc-id}`
    - the "Default VPC" is displayed on the EC2 dashboard, "Account Attributes"

### Settings

Check details of `config/settings.yml` and subdirectories;
modify the settings as required, esp. AWS details in the
instance defaults, like: AMI, AWS region, instance types and tags.

```bash
export CLUSTER_ENV='test' # or whatever {env} in config/settings/{env}.yml
export STAGE='test' # or whatever {stage} in config/deploy/{stage}.rb
bundle exec cap ${STAGE} ops:aws:check_settings
```

Note, the `CLUSTER_ENV` and `STAGE` here assume the default capistrano
paths are used for configs.  Below there are options for using custom
paths for configs that will override these settings.

#### Adding a Stage

Copy test settings into a few new `{stage}` files, i.e.:
- `config/deploy/{stage}.rb`
- `config/settings/{stage}.yml`

Review and modify all the values in those files.  Make sure you have the access
token details and the PEM access file.  

Alternatively, try the custom config paths described below.

#### Using Custom Config Paths

It's possible to use config paths that are outside the paths of this aws-ops
project.

Custom settings:  the default settings are in `config/settings.yml` merged with
`config/settings/test.yml`.  These can be replaced by a single custom settings file.
Use an absolute path to a settings file in the environment variable `CLUSTER_SETTINGS`, e.g.
```bash
export CLUSTER_SETTINGS="${HOME}/my_cluster/settings/test.yml"
```

Custom deploy:  the default deploy file is in `config/deploy.rb`.  This
path can be replaced with a custom deploy file, by giving an absolute path to
a deploy file in the environment variable `CLUSTER_DEPLOY_PATH`, e.g.
```bash
export CLUSTER_DEPLOY_PATH="${HOME}/my_cluster/deploy/deploy.rb"
```

Custom stage:  the default stage file is in `config/deploy/test.rb`.  This
path can be replaced with a custom stage file, by giving an absolute path to
a stage file in the environment variable `CLUSTER_STAGE_PATH`, e.g.
```bash
export CLUSTER_STAGE_PATH="${HOME}/my_cluster/stage/stage.rb"
```

Custom tasks:  the default tasks are in `lib/**/*.rake`.  These can be
supplemented (or overriden) by adding a custom tasks path.  Add an
absolute path to the environment variable `CLUSTER_TASKS_PATH`; this
should be the root path of all the tasks and it gets expanded to find
all the `*.rake` files anywhere below that path, e.g.
```bash
export CLUSTER_TASKS_PATH="${HOME}/my_cluster/lib"
```

WARNING: these are experimental features that have not been fully tested.


# General Use

Try to create new instances for
the services to provision (e.g., zookeeper and kafka).
```bash
# Always set the environment variables noted above to configure capistrano.
export STAGE={stage}
bundle exec cap ${STAGE} ops:aws:check_settings
bundle exec cap ${STAGE} zookeeper:nodes:create
bundle exec cap ${STAGE} zookeeper:nodes:find
bundle exec cap ${STAGE} kafka:nodes:create
bundle exec cap ${STAGE} kafka:nodes:find
# create nodes for additional services and then get the /etc/hosts details, e.g.
bundle exec cap ${STAGE} zookeeper:nodes:etc_hosts_public | sudo tee -a /etc/hosts
bundle exec cap ${STAGE} kafka:nodes:etc_hosts_public | sudo tee -a /etc/hosts
# ensure the hostnames in /etc/hosts match those in /config/deploy/{stage}.rb,
# then deploy the aws-ops code (be sure the code is pushed to github)
bundle exec cap ${STAGE} deploy:check
bundle exec cap ${STAGE} deploy
```

## Login shell on remote servers

The capistrano-shell plugin can drop you into a shell on a remote server into the
project deployment directory.
```bash
export STAGE={stage}
bundle exec cap ${STAGE} shell
```

## Provision Software with Capistrano

At this point, the capistrano tasks coordinate software installation and
configuration on the servers, identified by their `roles` in `config/deploy/{stage}.yml`.

Usually, the first things to provision are general OS utilities and build tools.
```bash
export STAGE={stage}
bundle exec cap -T | grep ubuntu
bundle exec cap ${STAGE} ubuntu:update
bundle exec cap ${STAGE} ubuntu:install:build_tools
bundle exec cap ${STAGE} ubuntu:install:java_8_oracle
bundle exec cap ${STAGE} ubuntu:install:network_tools
bundle exec cap ${STAGE} ubuntu:install:os_utils
```

Then provision services (see the "*:service:install" and "*:service:configure" tasks)
and then run services (see the "*:service:start" tasks).  Be careful to provision
configure and start services in order (e.g., zookeeper before anything that
depends on it).

## ZooKeeper

```bash
export STAGE={stage}
bundle exec cap -T | grep zookeeper
bundle exec cap ${STAGE} zookeeper:nodes:find
bundle exec cap ${STAGE} zookeeper:service:install
bundle exec cap ${STAGE} zookeeper:service:configure
bundle exec cap ${STAGE} zookeeper:service:start
bundle exec cap ${STAGE} zookeeper:service:status
# if all goes well, the status should report 'imok'
# Also check the 'srvr' details and look for leader/follower 'Mode';
# if the 'Mode: standalone', stop and restart the service until the
# 'Mode' shows the servers have formed a quorum and elected a leader.
bundle exec cap ${STAGE} zookeeper:service:command['srvr']
```

## ZooNavigator

```bash
export STAGE={stage}
bundle exec cap ${STAGE} zoonavigator:service:install
# If it fails, try it again (it might require the user to reconnect to enable docker)
bundle exec cap ${STAGE} zoonavigator:service:connections
# {stage}_zookeeper1:2181,{stage}_zookeeper2:2181,{stage}_zookeeper3:2181
```

Visit http://{stage}_zookeeper1:8001 and copy and paste the "connections"
information into the 'Connection string' on the login dialog.
Unless authorization is enabled, leave those fields blank

## Kafka

```bash
export STAGE={stage}
bundle exec cap ${STAGE} kafka:nodes:find
bundle exec cap ${STAGE} kafka:service:install
bundle exec cap ${STAGE} kafka:service:configure
bundle exec cap ${STAGE} kafka:service:start
bundle exec cap ${STAGE} kafka:service:status
```

If the `start` succeeds, it does not mean that Kafka is running.  When the `status`
indicates that Kafka is running, it's running.  If not, then check the Kafka logs
and trouble shoot the startup.  Sometimes Kafka fails to startup when the
Zookeeper `/kafka` node is first created; the logs will indicate that Kafka
created it but then couldn't find it.  Just wait a minute and try to start
Kafka again.  To view logs, try
```bash
export STAGE={stage}
bundle exec cap ${STAGE} kafka:service:tail_server_log["${STAGE}_kafka1"]
```

## Kafka Manager

TODO


# Explanation of enabling AWS hosts for Capistrano

## AWS EC2 Instance Information

To get AWS EC2 instance connection details, e.g.

```bash
export STAGE={stage}
bundle exec cap ${STAGE} zookeeper:nodes:create
# Wait a while for the Public IP and Public DNS values to be available, then:
bundle exec cap ${STAGE} zookeeper:nodes:find
# {
#   "ID": "i-0fd060e5124453b11",
#   "Type": "t2.medium",
#   "AMI ID": "ami-6e1a0117",
#   "A. Zone": "us-west-2a",
#   "State": "running",
#   "Tags": "Group: test_zookeeper; Name: test_zookeeper1; Service: zookeeper; Manager: dlweber; Stage: test",
#   "Key Pair": "test",
#   "Public IP": "55.27.247.237",
#   "Private IP": "172.31.22.75",
#   "Public DNS": "ec2-55-27-247-237.us-west-2.compute.amazonaws.com",
#   "Private DNS": "ip-172-31-22-75.us-west-2.compute.internal"
# }
# etc.
```

As noted above, there are also tasks to provide all the details
for `~/.ssh/config` and `/etc/hosts` for each service, e.g.
```bash
cap zookeeper:nodes:find                 # Find and describe all nodes
cap zookeeper:nodes:etc_hosts_private    # Compose entries for /etc/hosts using private IPs
cap zookeeper:nodes:etc_hosts_public     # Compose entries for /etc/hosts using public IPs
cap zookeeper:nodes:ssh_config_private   # Compose private entries for ~/.ssh/config for nodes
cap zookeeper:nodes:ssh_config_public    # Compose public entries for ~/.ssh/config for nodes
```

## Capistrano configuration

Once AWS EC2 instances are running, add their connection details to the
`config/deploy/*.rb` files and assign roles to each instance; e.g.

`server 'ec2-52-32-121-252.us-west-2.compute.amazonaws.com', user: 'ubuntu', roles: %w{zookeeper}`

If any instance serves multiple roles, just add them to the `roles`.  This can
allow installation of multiple services on one instance.  (The general assumption
of this project, however, is that an instance will host one service.)

If you want to use a `~/.ssh/config` file to rename and manage the public DNS entries for
your AWS instances, the connection details can be simplified to something like:

`server 'test_zookeeper1', user: 'ubuntu', roles: %w{zookeeper}`

In this case, the `~/.ssh/config` file contains:

```
Host test_zookeeper1
  Hostname ec2-52-32-121-252.us-west-2.compute.amazonaws.com
  user ubuntu
  IdentityFile ~/.ssh/an_aws_key.pem
  Port 22
```

Their connection details can be found using various `aws:ops` tasks or more specific
service tasks, like `zookeeper:nodes:find`.  

WARNING: if the systems are stopped and restarted, AWS can reassign the public
DNS entries, which must be updated again.  (There are solutions to this problem that
require additional IP management for instances.)

WARNING: Some service installation set environment variables in `/etc/profile.d/*.sh`, like
`KAFKA_HOME`, and add some entries to the PATH, like `$KAFKA_HOME/bin` to the `PATH`.
While these are available to a login shell, capistrano explicitly ignores them, see
http://capistranorb.com/documentation/faq/why-does-something-work-in-my-ssh-session-but-not-in-capistrano/#
To work around this, the values in `config/settings/{stage}.yml` that are used to set the
environment variables are also used explicitly in some capistrano tasks.  (Note, to avoid
confusion in this project, the settings/variable names for these are lower case.)


## Capistrano Deployment and Connections

The `config/deploy.rb` and the `config/deploy/{stage}.rb` files contain the connection
information for all the systems.  By default, `cap {stage} deploy` will deploy this code
repository to the `~/aws-ops` path (using conventional capistrano deployment directories).
Some of the capistrano tasks require access to the files in this project on the remote hosts,
so it's best to deploy this project and then run some system/service package installation
and configuration tasks.

To test the deployment, use
```bash
export STAGE={stage}
bundle exec cap ${STAGE} deploy:check
```
To run the deployment, use
```bash
export STAGE={stage}
bundle exec cap ${STAGE} deploy
```
To connect to a remote host, this project includes the `capistrano-shell` gem, e.g.
```bash
export STAGE={stage}
bundle exec cap ${STAGE} shell
# when multiple hosts are configured, it prompts for a specific host to connect to.
```

# Capistrano Namespaces and Services Available

See `bundle exec cap -T` for a complete listing.  Additional README docs might be
added to `lib/{service}/README.md`.

 - `ops:aws`
 - `hdfs` (TODO)
 - `kafka`
 - `kafka_manager` (TODO)
 - `mesos` (TODO)
 - `spark` (TODO)
 - `zookeeper`
 - `zoonavigator`
 - others include many common capistrano tasks, like `deploy`
 - see `find . -name '*.rake'` for details
 - task helpers are in `lib/**` and included in `Capfile`

# Licence

Copyright 2017 Darren L. Weber, Ph.D. under the Apache 2 license

This project was inspired by and adapted from:
https://github.com/adobe-research/spark-cluster-deployment
 - copyright 2014 Adobe Systems Incorporated under the Apache 2 license
 - initial adaptations are conversion of fabric (python) to capistrano (ruby)
 - initial project code here does not use the puppet code upstream
 - this project adopts the AWS API client for ruby (`aws-sdk` gem)
 - the adaptations are too substantial to constitute a fork
