PROJECT_PATH = Dir.pwd

require_relative 'lib/boot'

# ---
# Allow a custom config path for capistrano deploy and stages
# http://capistranorb.com/documentation/faq/how-can-i-set-capistrano-configuration-paths/

# default deploy_config_path is 'config/deploy.rb'
cluster_deploy_path = ENV['CLUSTER_DEPLOY_PATH']
if cluster_deploy_path
  set :deploy_config_path, File.expand_path(cluster_deploy_path)
end

# default stage_config_path is 'config/deploy'
cluster_stage_path = ENV['CLUSTER_STAGE_PATH']
if cluster_stage_path
  set :stage_config_path, File.expand_path(cluster_stage_path)
end

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

# ---
# Allow a custom rake tasks path
# http://capistranorb.com/documentation/faq/how-can-i-set-capistrano-configuration-paths/
cluster_tasks_path = ENV['CLUSTER_TASKS_PATH']
if cluster_tasks_path
  tasks_path = File.expand_path(cluster_tasks_path)
  Dir.glob("#{tasks_path}/**/*.rake").each { |r| import r }
end

# Load all the aws-ops tasks after any custom tasks, so
# the custom tasks can override these tasks when they use the
# same namespace and task names.
Dir.glob('lib/**/*.rake').each { |r| import r }

