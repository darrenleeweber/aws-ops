PROJECT_PATH=Dir.pwd

require 'highline/import'
def confirmation?(msg)
  cli = HighLine.new
  confirm = cli.ask("#{msg}; do it? [y/n] ") { |yn| yn.limit = 1, yn.validate = /[yn]/i }
  confirm.downcase == 'y'
end

require 'config'
app_env = ENV['AWS_ENV'] || 'development'
Config.load_and_set_settings(
  Config.setting_files('config', app_env)
)

require_relative 'lib/aws/aws_helpers'
require_relative 'lib/aws/aws_security_groups'
require_relative 'lib/settings/settings_security_groups'
require_relative 'lib/aws/aws_vpc'
require_relative 'lib/kafka/kafka_helpers'
require_relative 'lib/puppet/puppet_helpers'
require_relative 'lib/zookeeper/zookeeper_settings'
require_relative 'lib/zookeeper/zookeeper_helpers'

# ---
# Standard Capfile content below here.
# ---


# Load DSL and set up stages
require 'capistrano/setup'

# Include default deployment tasks
require 'capistrano/deploy'

# Load the SCM plugin appropriate to your project:
#
# require "capistrano/scm/hg"
# install_plugin Capistrano::SCM::Hg
# or
# require "capistrano/scm/svn"
# install_plugin Capistrano::SCM::Svn
# or
require 'capistrano/scm/git'
install_plugin Capistrano::SCM::Git

# Include tasks from other gems included in your Gemfile
#
# For documentation on these, see for example:
#
#   https://github.com/capistrano/rvm
#   https://github.com/capistrano/rbenv
#   https://github.com/capistrano/chruby
#   https://github.com/capistrano/bundler
#   https://github.com/capistrano/rails
#   https://github.com/capistrano/passenger
#
# require "capistrano/rvm"
# require "capistrano/rbenv"
# require "capistrano/chruby"
# require "capistrano/bundler"
# require "capistrano/rails/assets"
# require "capistrano/rails/migrations"
# require "capistrano/passenger"
require 'capistrano/shell'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob('lib/**/*.rake').each { |r| import r }

