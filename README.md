# aws-ops
Utils to provision services on AWS

Incomplete - work in progress.

# Goals
 - use ruby AWS API client to provision AWS resources
 - use capistrano for service installation/configuration
 - use bash scripts and/or puppet provision tools
 - use convenient capistrano/rake tasks
 - manage settings with the config gem
    - default settings are in config/settings.yml
    - AWS_ENV=development (default)
        - settings are merged with config/settings/development.yml
    - AWS_ENV=production
        - settings are merged with config/settings/production.yml
 - TODO: persist the AWS resource details in a local DB
   - or use AWS discovery services to find them dynamically
   
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
`/config/settings/{AWS_ENV}.rb` instances.

```bash
# Setup your AWS credentials using ENV values or config/setting.yml
bundle exec cap dev ops:aws:check_credentials
```

Once any instance is created and assigned a public DNS, it can be added to
your `~/.ssh/config` file, along with the required AWS Key Pair used to
access it.  It recommended that `Host` value matches the instance name in
`config/settings/{stage}.yml` and it's essential that the `Host` value
is used in the Capistrano `config/deploy/{stage}.rb` settings.

An example of an `~/.ssh/config` entry:
```
Host <Instance name in your config/settings/{stage}.yml>
  Hostname {AWS_EC2_PUBLIC_DNS}
  user {ubuntu or something}
  IdentityFile ~/.ssh/{AWS_Key_Pair_Name}.pem
  Port 22
```

To test the ssh access to any AWS EC2 public DNS, try something like:
```bash
ssh -i ~/.ssh/{AWS_Key_Pair_Name}.pem {user}@{AWS_EC2_PUBLIC_DNS}
```

If that works and the `~/.ssh/config` entry is made, try:
```bash
ssh {HOST value from ~/.ssh/config}
```


### Settings

Check details of config/settings.yml and subdirectories;
modify the settings as required, esp. AWS details in the
instance defaults, like: AMI, AWS region, instance types and tags.
```bash
AWS_ENV=development bundle exec cap development ops:aws:check_settings
AWS_ENV=production  bundle exec cap production ops:aws:check_settings
AWS_ENV=stage       bundle exec cap stage ops:aws:check_settings
AWS_ENV=test        bundle exec cap test ops:aws:check_settings
```

# Use
```bash
# Test creating a new instance
bundle exec cap dev ops:aws:ec2:create_instance_test
# Create a named instance using the settings params
bundle exec cap dev ops:aws:ec2:create_instance_by_name['dev_zookeeper1']
# Find an instance by tags
bundle exec cap dev ops:aws:ec2:find_instance_by_name['dev_zookeeper1']
# Record instance public DNS in the servers/roles details in
# config/deploy/*.rb as required. (This is not automated yet.)
```

# AWS EC2 Instance Information

To get AWS EC2 instance connection details, e.g.

```
$ AWS_ENV=test bundle exec cap test zookeeper:nodes:create
# Wait a while for the Public IP and Public DNS values to be available, then:
$ AWS_ENV=test bundle exec cap test zookeeper:nodes:find
ID:		i-08ccd8ef0540b2b15
Type:		t2.micro
AMI ID:		ami-6e1a0117
State:		running
Tags:		Group: test_zookeeper; Name: test_zookeeper1; Service: zookeeper
Public IP:	52.32.121.252
Public DNS:	ec2-52-32-121-252.us-west-2.compute.amazonaws.com
Private DNS:	ip-172-31-23-169.us-west-2.compute.internal
```

# Capistrano configuration

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
service tasks, like `zookeeper:nodes:find`.  NOTE: if the systems are stopped or
restarted, AWS could reassign the public DNS entries and wipe out these settings, which
have to be updated again.

# Capistrano Deployment and Connections

The `config/deploy.rb` and the `config/deploy/{stage}.rb` files contain the connection
information for all the systems.  By default, `cap {stage} deploy` will deploy this code
repository to the `~/aws-ops` path (using conventional capistrano deployment directories).
Some of the capistrano tasks require access to the files in this project on the remote hosts,
so it's best to deploy this project and then run run some system/service package installation
and configuration tasks.

To test the deployment, use
```bash
AWS_ENV={stage} bundle exec cap {stage} deploy:check
```
To run the deployment, use
```bash
AWS_ENV={stage} bundle exec cap {stage} deploy
```
To connect to a remote host, this project includes the `capistrano-shell` gem, e.g.
```bash
AWS_ENV={stage} bundle exec cap {stage} shell
# when multiple hosts are configured, it prompts for a specific host to connect to.
```

# Capistrano Namespaces and Services Available
 - `ops:aws`
 - `hdfs`
 - `spark`
 - `zookeeper`
 - TODO: `mesos` and others
 - the rest are capistrano defaults, like `deploy`
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
