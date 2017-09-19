require 'aws-sdk-ec2'
require_relative 'aws_security_groups'
require_relative 'aws_vpc'

# Utilities for working with the AWS API, see
# http://docs.aws.amazon.com/sdk-for-ruby/v2/developer-guide/examples.html
# http://docs.aws.amazon.com/sdk-for-ruby/v2/developer-guide/ec2-examples.html
module AwsHelpers

  module_function

  def config
    # http://docs.aws.amazon.com/sdk-for-ruby/v2/developer-guide/setup-config.html
    Aws.config.update(credentials: credentials)
  end

  def credentials
    @aws_credentials ||= begin
      access_key_id = Settings.aws.access_key_id || ENV['AWS_ACCESS_KEY_ID']
      secret_access_key = Settings.aws.secret_access_key || ENV['AWS_SECRET_ACCESS_KEY']
      Aws::Credentials.new(access_key_id, secret_access_key)
    end
  end

  def credentials?
    credentials
    true
  rescue StandardError
    false
  end

  def ec2(region = nil)
    @ec2 ||= begin
      region ||= Settings.aws.region
      Aws::EC2::Resource.new(region: region)
    end
  end

  # http://docs.aws.amazon.com/sdk-for-ruby/v2/developer-guide/ec2-example-create-instance.html
  # params = {
  #   "region": "us-west-2",
  #   "image_id": "ami-6e1a0117",
  #   "min_count": 1,
  #   "max_count": 1,
  #   "instance_type": "t2.micro",
  #   "availability_zone": "us-west-2a",
  #   "tag_name": "default",
  #   "tag_group": "default"
  # }
  def ec2_create(params)
    AwsSecurityGroups.ec2_security_groups_validate(params['security_groups'])
    puts "Using AWS region: #{params['region']}"
    ec2 = Aws::EC2::Resource.new(region: params['region'])

    puts "Creating EC2 instance with tag:Name - #{params['tag_name']}"
    instances = ec2.create_instances(
      image_id: params['image_id'],
      min_count: params['min_count'],
      max_count: params['max_count'],
      key_name: params['key_name'],
      security_group_ids: params['security_groups'],
      # user_data: encoded_script,
      instance_type: params['instance_type'],
      placement: {
        availability_zone: params['availability_zone']
      },
      # subnet_id: 'SUBNET_ID',
      # iam_instance_profile: {
      #   arn: 'arn:aws:iam::' + 'ACCOUNT_ID' + ':instance-profile/aws-opsworks-ec2-role'
      # }
    )

    instance_ids = instances.map(&:id)
    ec2_wait_instance_startup(instance_ids)
    instances.each { |i| ec2_add_tags(i, params) }
    instances.each { |i| ec2_instance_info(i) }
    instances
  end

  def ec2_add_tags(inst, tags)
    name = tags['tag_name'] || ''
    group = tags['tag_group'] || ''
    manager = tags['tag_manager'] || ''
    service = tags['tag_service'] || ''
    stage = tags['tag_stage'] || ''
    inst.create_tags(
      tags: [
        { key: 'Name',  value: name },
        { key: 'Group', value: group },
        { key: 'Manager', value: manager },
        { key: 'Service', value: service },
        { key: 'Stage', value: stage }
      ]
    )
  end

  # Get all instances with tag key 'Group'
  def ec2_find_group_instances(tag_value)
    ec2_find_instances_by_tag('Group', tag_value)
  end

  # Get all instances with tag key 'Group'
  def ec2_find_name_instances(tag_value)
    ec2_find_instances_by_tag('Name', tag_value)
  end

  # Get all instances with tag key 'Service'
  def ec2_find_service_instances(tag_value)
    ec2_find_instances_by_tag('Service', tag_value)
  end

  # Get all instances with tag key 'Stage'
  def ec2_find_stage_instances(tag_value)
    ec2_find_instances_by_tag('Stage', tag_value)
  end

  # Find an instance
  def ec2_find_instance(instance_id)
    i = ec2.instance(instance_id)
    raise 'Instance not found' if i.nil?
    i
  end

  # Get all instances by tag
  def ec2_find_instances_by_tag(tag, value)
    filter = { name: "tag:#{tag}", values: [value] }
    collection = ec2.instances(filters: [filter])
    collection.to_a
  end

  def ec2_instance_tag_name(i)
    i.tags.select { |t| t.key == 'Name' }.map(&:value).first
  end

  def ec2_instance_tag_name?(i, tag_name)
    ec2_instance_tag_name(i) == tag_name
  end

  # Extract instance information
  # @param inst [Aws::EC2::Instance]
  # @return [Hash]
  def ec2_instance_info(inst)
    {
      'ID'          => inst.id.to_s,
      'Type'        => inst.instance_type.to_s,
      'AMI ID'      => inst.image_id.to_s,
      'A. Zone'     => inst.placement.availability_zone.to_s,
      'State'       => inst.state.name.to_s,
      'Tags'        => inst.tags.map { |t| "#{t.key}: #{t.value}" }.join('; '),
      'Key Pair'    => inst.key_name.to_s,
      'Public IP'   => inst.public_ip_address.to_s,
      'Private IP'  => inst.private_ip_address.to_s,
      'Public DNS'  => inst.public_dns_name.to_s,
      'Private DNS' => inst.private_dns_name.to_s
    }
  end

  # Print instances information
  # @param instances [Array<Aws::EC2::Instance>]
  # @return [Array<String>]
  def ec2_instances_describe(instances)
    instances.collect { |i| ec2_instance_describe(i) }
  end

  # Print instance information
  # @param instance [Aws::EC2::Instance]
  # @return String
  def ec2_instance_describe(inst)
    json = ec2_instance_info(inst).to_json
    JSON.pretty_generate(JSON.parse(json))
  end

  # Content for /etc/hosts
  # @param i [Aws::EC2::Instance]
  # @param public [Boolean] use public or private IP
  def ec2_instance_etc_hosts(i, public = true)
    ip = public ? i.public_ip_address : i.private_ip_address
    public_dns = i.public_dns_name.to_s
    private_dns = i.private_dns_name.to_s
    "#{ip}\t\t#{public_dns}\t\t#{private_dns}\t\t{HOST}" # template for HOST in settings
  end

  # Content for ~/.ssh/config
  # @param i [Aws::EC2::Instance]
  # @param public [Boolean] use public or private DNS name
  def ec2_instance_ssh_config(i, public = true)
    hostname = public ? i.public_dns_name : i.private_dns_name
    # Use templates for HOST and USER (values provided in settings)
    "Host {HOST}\n" \
      "\tUser {USER}\n" \
      "\tHostname #{hostname}\n" \
      "\tIdentityFile ~/.ssh/#{i.key_name}.pem\n" \
      "\tPort 22\n"
  end

  # Start an instance
  def ec2_start_instance(instance_id)
    i = ec2_find_instance(instance_id)
    i.start
    ec2_wait_instance_startup([i.id])
  end

  # Stop an instance
  def ec2_stop_instance(instance_id)
    i = ec2_find_instance(instance_id)
    i.stop
    ec2_wait_instance_stopped([i.id])
  end

  # Reboot an instance
  def ec2_reboot_instance(instance_id)
    i = ec2_find_instance(instance_id)
    i.reboot
    ec2_wait_instance_startup([i.id])
  end

  # Stop an instance
  def ec2_terminate_instance(instance_id)
    i = ec2_find_instance(instance_id)
    i.terminate
    ec2_wait_instance_terminated([i.id])
  end

  # See ec2.client.waiter_names for options to wait
  def ec2_wait_instance_startup(instance_ids)
    # Wait for the instance to be created, running, and passed status checks
    puts "instances #{instance_ids}: waiting to pass status checks"
    ec2.client.wait_until(:instance_status_ok, instance_ids: instance_ids)
    puts "instances #{instance_ids}: created, running, and passed status checks"
  end

  # See ec2.client.waiter_names for options to wait
  def ec2_wait_instance_stopped(instance_ids)
    # Wait for the instance to be created, running, and passed status checks
    puts "instances #{instance_ids}: waiting to stop"
    ec2.client.wait_until(:instance_stopped, instance_ids: instance_ids)
    puts "instances #{instance_ids}: stopped"
  end

  # See ec2.client.waiter_names for options to wait
  def ec2_wait_instance_terminated(instance_ids)
    # Wait for the instance to be created, running, and passed status checks
    puts "instances #{instance_ids}: waiting to terminate"
    ec2.client.wait_until(:instance_terminated, instance_ids: instance_ids)
    puts "instances #{instance_ids}: terminated"
  end

end

