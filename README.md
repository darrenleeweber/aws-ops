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

# Install
```bash
git clone https://github.com/darrenleeweber/aws-ops.git
cd aws-ops
bundle install
bundle exec cap -T
```

# Configure
```bash
# Setup your AWS credentials using ENV values or config/setting.yml
bundle exec cap dev ops:aws:check_credentials

# Check details of config/settings.yml and subdirectories
# Modify the settings as required, esp. AWS details in the
# instance defaults, like: AMI, AWS region, instance types and tags
AWS_ENV=development bundle exec cap dev ops:aws:check_settings
AWS_ENV=production  bundle exec cap dev ops:aws:check_settings
AWS_ENV=test        bundle exec cap dev ops:aws:check_settings
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

# Capistrano Namespaces
 - `ops:aws`
 - `hdfs`
 - `spark`
 - `zookeeper`
 - TODO: `mesos` and others
 - the rest are capistrano defaults, like `deploy`
 - see `lib/capistrano/tasks` for details
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
