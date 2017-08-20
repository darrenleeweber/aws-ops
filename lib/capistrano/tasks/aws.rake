
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
          puts "Check the config/settings.yml or config/settings/{env} for details"
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

      desc 'Find an EC2 instance by GROUP'
      task :find_instances_by_group, :group do |task, args|
        group = args.group || Settings.aws.tag_group
        AwsHelpers.ec2_find_group_instances(group)
      end

      desc 'Find an EC2 instance by NAME'
      task :find_instance_by_name, :name do |task, args|
        AwsHelpers.ec2_find_name_instances(args.name)
      end

      desc 'Find an EC2 instance by ID'
      task :find_instance, :instance_id do |task, args|
        AwsHelpers.ec2_find_instance(args.instance_id)
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

