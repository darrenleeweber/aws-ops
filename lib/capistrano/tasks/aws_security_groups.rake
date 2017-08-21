
namespace :ops do
  namespace :aws do
    namespace :security_groups do

      def security_group_keys
        Settings.aws.keys.select { |k| k.to_s.include? 'security_group' }
      end

      def security_group_settings
        security_group_keys
          .map { |k| Settings.aws[k] }
          .reject { |sg| sg.group_name.nil? }
      end

      def security_group_settings_names
        security_group_settings.map(&:group_name)
      end

      def security_group_settings_find(group_name)
        security_group_settings.find { |sg| sg.group_name == group_name }
      end

      def security_group_params(sg_settings)
        JSON.parse(sg_settings.to_json)
      end

      desc 'List security group settings in this project'
      task :list do
        security_group_settings.each { |sg| puts security_group_params(sg) }
      end

      desc 'Create security group'
      task :create, :group_name do |task, args|
        sg_settings = security_group_settings_find(args.group_name)
        params = security_group_params(sg_settings)
        sg = AwsSecurityGroups.ec2_security_group_create(params)
        AwsSecurityGroups.ec2_security_group_describe(sg) unless sg.nil?
      end

      desc 'Delete a security group by GROUP-NAME'
      task :delete, :group_name do |task, args|
        sg = AwsSecurityGroups.ec2_security_group_find(args.group_name)
        AwsSecurityGroups.ec2_security_group_delete(sg) unless sg.nil?
      end

      desc 'Find and describe all security groups'
      task :find do
        AwsSecurityGroups.describe_security_groups
      end

      desc 'Find a security group by GROUP-NAME'
      task :find_by_name, :group_name do |task, args|
        sg = AwsSecurityGroups.ec2_security_group_find(args.group_name)
        AwsSecurityGroups.ec2_security_group_describe(sg) unless sg.nil?
      end

    end
  end
end

