require 'config'

# CLUSTER_SETTINGS="file1.yml,file2.yml,...,fileN.yml"
cluster_settings = ENV['CLUSTER_SETTINGS']
if cluster_settings
  files = cluster_settings.split(',').map(&:strip)
  Config.load_and_set_settings(files)
else
  cluster_env = ENV['CLUSTER_ENV'] || 'test'
  Config.load_and_set_settings(
    Config.setting_files('config', cluster_env)
  )
end

require_relative 'aws/aws_helpers'
require_relative 'aws/aws_security_groups_settings'
require_relative 'aws/aws_security_groups'
require_relative 'aws/aws_vpc'
AwsHelpers.config

require_relative 'service/service_manager'
require_relative 'service/service_settings'

require_relative 'ubuntu/ubuntu_helper'
require_relative 'redhat/redhat_helper'

require_relative 'kafka/kafka_helpers'
require_relative 'zookeeper/zookeeper_helpers'

