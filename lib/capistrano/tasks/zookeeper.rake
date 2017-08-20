
namespace :zookeeper do

  SERVICE = 'zookeeper'.freeze

  def zookeeper_keys
    Settings.aws.keys.select { |k| k.to_s.include? 'zookeeper' }
  end

  def zookeeper_settings
    zookeeper_keys.map { |k| Settings.aws[k] }
  end

  def zookeeper_settings_names
    zookeeper_settings.map(&:tag_name)
  end

  def zookeeper_instances
    zookeeper_settings_names.map do |tag_name|
      AwsHelpers.ec2_find_name_instances(tag_name)
    end.flatten
  end

  def zookeeper_instance_names
    zookeeper_instances.map { |i| AwsHelpers.ec2_instance_tag_name(i) }
  end

  desc 'Create Zookeeper nodes'
  task :create do
    # Attempts to be idempotent, but if details of settings change,
    # it cannot inspect everything to detect updates or instance replacements.
    # To replace instances and change their settings, terminate them and recreate them.
    # TODO: Can this task auto-update the config/deploy/{env} servers?
    existing_names = zookeeper_instance_names
    zookeeper_settings.each do |params|
      # Only create a new one if it does not exist, based on tag:Name
      unless existing_names.include? params.tag_name
        AwsHelpers.ec2_create params
      end
    end
  end

  desc 'Terminate Zookeeper nodes'
  task :terminate do
    # Attempts to be idempotent, but if details of settings change,
    # it cannot inspect everything to detect updates or instance replacements.
    # To replace instances and change their settings, terminate them and recreate them.
    # TODO: Can this task auto-update the config/deploy/{env} servers?
    exit unless confirmation?('WARNING: terminating zookeeper can crash services')
    zookeeper_settings.each do |params|
      # Only terminate an existing instance that matches our settings
      instances = AwsHelpers.ec2_find_name_instances(params.tag_name)
      raise 'Found too many instances' if instances.length > 1
      next if instances.empty?
      next unless confirmation?("Terminate: #{params.tag_name}")
      i = instances.first
      AwsHelpers.ec2_terminate_instance(i.id) unless i.nil?
    end
  end

  desc 'Find and describe all Zookeeper nodes'
  task :find do
    AwsHelpers.ec2_find_service_instances(SERVICE)
  end


  namespace :service do
    desc 'Install Zookeeper service'
    task :install do
      on roles(:zookeeper), in: :parallel do |host|
        # PuppetHelpers.puppet_apply('zookeeper.pp')
      end
    end

    desc 'Start Zookeeper service'
    task :start do
      on roles(:zookeeper), in: :parallel do |host|
        sudo('service zookeeper restart')
      end
    end

    desc 'Status of Zookeeper service'
    task :status do
      on roles(:zookeeper), in: :parallel do |host|
        sudo('service zookeeper status')
      end
    end

    desc 'Stop Zookeeper service'
    task :stop do
      on roles(:zookeeper), in: :parallel do |host|
        sudo('service zookeeper stop')
      end
    end
  end
end

