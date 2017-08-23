# config valid only for current version of Capistrano
lock "3.8.2"

set :application, 'aws-ops'
set :repo_url, 'git@github.com:darrenleeweber/aws-ops.git'

#####
# AWS SSH Connection Notes:

# The ssh_options can be managed here or they can be managed in ~/.ssh/config;
# with these options commented out, the AWS Key Pair should be in ~/.ssh/config.
# If the AWS Key Pair is different for each deploy-stage, it should be possible
# to redefine the ssh_options in config/deploy/{stage}.rb

# An example of an ~/.ssh/config entry:
# Host <An instance name in your config/settings/{stage}.yml>
#   Hostname <AWS_EC2_PUBLIC_DNS>
#   user {ubuntu or something}
#   IdentityFile ~/.ssh/<Your AWS Key Pair Name>.pem
#   Port 22

# set :ssh_options, {
#   forward_agent: true,
#   auth_methods: ['publickey'],
#   keys: ["#{Dir.home}/.ssh/<Your AWS Key Pair Name>.pem"]
# }

#####


# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"
set :deploy_to, '~/aws-ops'

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", "config/secrets.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5
