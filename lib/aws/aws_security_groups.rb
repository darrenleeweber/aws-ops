require 'aws-sdk-ec2'
require_relative 'aws_security_groups_settings'

# Utilities for working with the AWS API, see
# http://docs.aws.amazon.com/sdk-for-ruby/v2/developer-guide/ec2-working-with-security-groups.html
module AwsSecurityGroups

  module_function

  def ec2(region = nil)
    @ec2 ||= begin
      region ||= Settings.aws.region
      Aws::EC2::Client.new(region: region)
    end
  end

  def ec2_security_groups
    ec2.describe_security_groups.security_groups
  end

  def ec2_security_group_delete(sg)
    ec2.delete_security_group(group_id: sg.group_id)
  end

  def ec2_security_group_describe(sg)
    puts JSON.pretty_generate(JSON.parse(sg.to_h.to_json))
  end

  # @param group_name [String]
  def ec2_security_group_find(group_name)
    ec2_security_groups.find { |sg| sg.group_name == group_name }
  end

  # @param security_group_names [Array<String>]
  def ec2_security_groups_validate(security_group_names)
    security_group_names.all? do |group_name|
      sg = ec2_security_group_find(group_name) || begin
        # Cannot find it, try to create it
        sg_settings = AwsSecurityGroupsSettings.find(group_name)
        raise "Not Found: security group settings for '#{group_name}'" if sg_settings.nil?
        params = AwsSecurityGroupsSettings.to_params(sg_settings)
        ec2_security_group_create(params)
      end
    end
  end

  # The following example creates a security group MyGroovySecurityGroup in the
  # us-west-2 region on a VPC with the ID VPC_ID. In the example, the security
  # group is allowed access over port 22 (SSH) from all addresses (CIDR block 0.0.0.0/0)
  # and is given the description "Security group for MyGroovyInstance".
  # Then, the security group's ID is displayed.
  def ec2_security_group_create(params)
    # params = JSON.parse(Settings.aws.test_ssh_security_group.to_json)
    sg = ec2.create_security_group(
      group_name:  params['group_name'],
      description: params['description'],
      vpc_id: params['vpc_id']
    )
    # Add rules to the security group (e.g. allow inbound SSH)
    params['authorize_ingress']['group_id'] = sg.group_id
    ec2.authorize_security_group_ingress(params['authorize_ingress'])
    # adding tags is broken, see below
    # ec2_security_group_add_tags(sg, params)
    ec2_security_group_find(params['group_name'])
  rescue Aws::EC2::Errors::InvalidGroupDuplicate
    puts "Security group_name '#{params['group_name']}' already exists."
    ec2_security_group_find(params['group_name'])
  end

  # def ec2_security_group_add_tags(sg, tags)
  #   name = tags['tag_name'] || ''
  #   group = tags['tag_group'] || ''
  #   manager = tags['tag_manager'] || ''
  #   stage = tags['tag_stage'] || ''
  #   #
  #   # NoMethodError: undefined method `create_tags' for #<Seahorse::Client::Response:0x00564fd3e6c750>
  #   #
  #   # or
  #   #
  #   # NoMethodError: undefined method `create_tags' for #<Aws::EC2::Types::SecurityGroup:0x00564fd429ef58>
  #   #
  #   sg.create_tags(
  #     tags: [
  #             { key: 'Name',  value: name },
  #             { key: 'Group', value: group },
  #             { key: 'Manager', value: manager },
  #             { key: 'Stage', value: stage }
  #           ]
  #   )
  # end

  def describe_security_groups
    ec2_security_groups.each { |sg| ec2_security_group_describe(sg) }
  end

  #----
  # Code below is from
  # http://docs.aws.amazon.com/sdk-for-ruby/v2/developer-guide/ec2-working-with-security-groups.html

  # def describe_security_groups
  #   ec2_security_groups.each do |security_group|
  #     puts "\n"
  #     puts "*" * (security_group.group_name.length + 12)
  #     puts "Group Name: #{security_group.group_name}"
  #     puts "Group ID: #{security_group.group_id}"
  #     puts "Description: #{security_group.description}"
  #     puts "VPC ID: #{security_group.vpc_id}"
  #     puts "Owner ID: #{security_group.owner_id}"
  #     if security_group.ip_permissions.count > 0
  #       puts "=" * 22
  #       puts "IP Permissions:"
  #       security_group.ip_permissions.each do |ip_permission|
  #         describe_ip_permission(ip_permission)
  #       end
  #     end
  #     if security_group.ip_permissions_egress.count > 0
  #       puts "=" * 22
  #       puts "IP Permissions Egress:"
  #       security_group.ip_permissions_egress.each do |ip_permission|
  #         describe_ip_permission(ip_permission)
  #       end
  #     end
  #     if security_group.tags.count > 0
  #       puts "=" * 22
  #       puts "Tags:"
  #       security_group.tags.each do |tag|
  #         puts "  #{tag.key} = #{tag.value}"
  #       end
  #     end
  #   end
  # end

  # def describe_ip_permission(ip_permission)
  #   puts "-" * 22
  #   puts "IP Protocol: #{ip_permission.ip_protocol}"
  #   puts "From Port: #{ip_permission.from_port.to_s}"
  #   puts "To Port: #{ip_permission.to_port.to_s}"
  #   if ip_permission.ip_ranges.count > 0
  #     puts "IP Ranges:"
  #     ip_permission.ip_ranges.each do |ip_range|
  #       puts "  #{ip_range.cidr_ip}"
  #     end
  #   end
  #   if ip_permission.ipv_6_ranges.count > 0
  #     puts "IPv6 Ranges:"
  #     ip_permission.ipv_6_ranges.each do |ipv_6_range|
  #       puts "  #{ipv_6_range.cidr_ipv_6}"
  #     end
  #   end
  #   if ip_permission.prefix_list_ids.count > 0
  #     puts "Prefix List IDs:"
  #     ip_permission.prefix_list_ids.each do |prefix_list_id|
  #       puts "  #{prefix_list_id.prefix_list_id}"
  #     end
  #   end
  #   if ip_permission.user_id_group_pairs.count > 0
  #     puts "User ID Group Pairs:"
  #     ip_permission.user_id_group_pairs.each do |user_id_group_pair|
  #       puts "  ." * 7
  #       puts "  Group ID: #{user_id_group_pair.group_id}"
  #       puts "  Group Name: #{user_id_group_pair.group_name}"
  #       puts "  Peering Status: #{user_id_group_pair.peering_status}"
  #       puts "  User ID: #{user_id_group_pair.user_id}"
  #       puts "  VPC ID: #{user_id_group_pair.vpc_id}"
  #       puts "  VPC Peering Connection ID: #{user_id_group_pair.vpc_peering_connection_id}"
  #     end
  #   end
  # end

end

