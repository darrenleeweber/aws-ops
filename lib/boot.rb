require 'config'
app_env = ENV['AWS_ENV'] || 'development'
Config.load_and_set_settings(
  Config.setting_files('config', app_env)
)

require_relative 'aws/aws_helpers'
require_relative 'aws/aws_security_groups_settings'
require_relative 'aws/aws_security_groups'
require_relative 'aws/aws_vpc'

require_relative 'service/service_manager'
require_relative 'service/service_settings'

require_relative 'kafka/kafka_helpers'
require_relative 'zookeeper/zookeeper_helpers'

require 'highline/import'
def confirmation?(msg)
  cli = HighLine.new
  confirm = cli.ask("#{msg}; do it? [y/n] ") { |yn| yn.limit = 1, yn.validate = /[yn]/i }
  confirm.casecmp('y').zero?
end
