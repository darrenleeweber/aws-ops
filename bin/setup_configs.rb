#!/usr/bin/env ruby

SCRIPT_PATH=File.absolute_path(__FILE__)
SCRIPT_FILE=File.basename(__FILE__)
SCRIPT_DIR=File.dirname(SCRIPT_PATH)
CONFIG_DIR=File.absolute_path(File.join(SCRIPT_DIR, '..', 'config'))

CLUSTER_PATH=ARGV[0]
if (CLUSTER_PATH.nil? || CLUSTER_PATH.empty? || CLUSTER_PATH =~ /-h/); then
  puts "#{SCRIPT_FILE} {cluster_path}"
  exit
end

CLUSTER_ENV = File.join(CLUSTER_PATH, 'config.sh')
CLUSTER_CONFIG = File.join(CLUSTER_PATH, 'config')
CLUSTER_STAGE_NAME = File.split(CLUSTER_PATH).last
settings_test  = File.join(CLUSTER_CONFIG, 'settings', 'test.yml')
settings_stage = File.join(CLUSTER_CONFIG, 'settings', "#{CLUSTER_STAGE_NAME}.yml")
deploy_test  = File.join(CLUSTER_CONFIG, 'deploy', 'test.rb')
deploy_stage = File.join(CLUSTER_CONFIG, 'deploy', "#{CLUSTER_STAGE_NAME}.rb")

if File.exist?(CLUSTER_PATH)
  puts
  puts "ERROR: this config path exists, doing nothing!"
  puts
else
  system("mkdir -p #{CLUSTER_PATH}")
  system("cp -r #{CONFIG_DIR} #{CLUSTER_PATH}")
  system("mv #{settings_test} #{settings_stage}")
  system("mv #{deploy_test} #{deploy_stage}")

  config_sh = <<EOF
#!/bin/bash
export CLUSTER_CONFIG=#{CLUSTER_CONFIG}
export CLUSTER_SETTINGS=${CLUSTER_CONFIG}/settings/#{CLUSTER_STAGE_NAME}.yml
export CLUSTER_DEPLOY_PATH=${CLUSTER_CONFIG}/deploy.rb
export CLUSTER_STAGE_PATH=${CLUSTER_CONFIG}/deploy
EOF
  File.write(CLUSTER_ENV, config_sh)
end

Dir.glob("#{CLUSTER_PATH}/**/*").each do |f|
  puts f
end
puts
puts "Files to edit:"
puts deploy_stage
puts settings_stage
puts
puts "Cluster settings environment:"
puts "source #{CLUSTER_ENV}"

