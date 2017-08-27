
namespace :ops do
  namespace :aws do
    desc 'Check credentials for AWS SDK'
    task :check_credentials do
      puts AwsHelpers.aws_credentials? ? 'OK' : 'Failed to init credentials'
    end

    desc 'Check AWS settings'
    task :check_settings do
      puts JSON.pretty_generate(JSON.parse(Settings.aws.to_json))
    end

    namespace :ec2 do
      desc 'Create an EC2 instance by NAME'
      task :create_instance_by_name, :name do |task, args|
        instance_params = Settings.aws[args.name]
        if instance_params.nil?
          puts "Settings.aws['#{args.name}'] does not exist"
          puts 'Check the config/settings.yml or config/settings/{env} for details'
        else
          AwsHelpers.ec2_create instance_params
        end
      end

      desc 'Create a default EC2 instance'
      task :create_instance_default do
        AwsHelpers.ec2_create Settings.aws.instance_default
      end

      desc 'Create a test EC2 instance'
      task :create_instance_test do
        AwsHelpers.ec2_create Settings.aws.instance_test
      end

      desc 'Find an EC2 instance by "Group" tag'
      task :find_instances_by_group, :group do |task, args|
        instances = AwsHelpers.ec2_find_group_instances(args.group)
        instances.each { |i| AwsHelpers.ec2_instance_info(i) }
      end

      desc 'Find an EC2 instance by "Name" tag'
      task :find_instance_by_name, :name do |task, args|
        instances = AwsHelpers.ec2_find_name_instances(args.name)
        instances.each { |i| AwsHelpers.ec2_instance_info(i) }
      end

      desc 'Find an EC2 instance by "Service" tag'
      task :find_instances_by_service, :service do |task, args|
        instances = AwsHelpers.ec2_find_service_instances(args.service)
        instances.each { |i| AwsHelpers.ec2_instance_info(i) }
      end

      desc 'Find an EC2 instance by "Stage" tag'
      task :find_instances_by_stage, :stage do |task, args|
        stage = args.stage || fetch(:stage)
        instances = AwsHelpers.ec2_find_stage_instances(stage)
        instances.each { |i| AwsHelpers.ec2_instance_info(i) }
      end

      desc 'Find an EC2 instance by ID'
      task :find_instance, :instance_id do |task, args|
        i = AwsHelpers.ec2_find_instance(args.instance_id)
        AwsHelpers.ec2_instance_info(i)
      end

      desc 'Start an EC2 instance by ID'
      task :start_instance, :instance_id do |task, args|
        AwsHelpers.ec2_start_instance(args.instance_id)
      end

      desc 'Stop an EC2 instance by ID'
      task :stop_instance, :instance_id do |task, args|
        AwsHelpers.ec2_stop_instance(args.instance_id)
      end
    end
  end
end

