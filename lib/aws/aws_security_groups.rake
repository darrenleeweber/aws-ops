require_relative 'aws_security_groups_settings'
require_relative 'aws_security_groups'

namespace :ops do
  namespace :aws do
    namespace :security_groups do

      desc 'List security group settings in this project'
      task :check_settings do
        AwsSecurityGroupsSettings.security_groups.each do |sg|
          puts AwsSecurityGroupsSettings.to_params(sg)
        end
      end

      desc 'Create security group'
      task :create, :group_name do |task, args|
        sg_settings = AwsSecurityGroupsSettings.find(args.group_name)
        raise "Not Found: security group '#{args.group_name}'" if sg_settings.nil?
        params = AwsSecurityGroupsSettings.to_params(sg_settings)
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

