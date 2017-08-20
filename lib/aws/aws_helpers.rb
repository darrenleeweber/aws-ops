require 'aws-sdk'

# Utilities for working with the AWS API, see
# http://docs.aws.amazon.com/sdk-for-ruby/v2/developer-guide/examples.html
# http://docs.aws.amazon.com/sdk-for-ruby/v2/developer-guide/ec2-examples.html
module AwsHelpers
  module_function

  def aws_credentials
    # http://docs.aws.amazon.com/sdk-for-ruby/v2/developer-guide/setup-config.html
    @aws_credentials ||= begin
      access_key_id = Settings.aws.access_key_id || ENV['AWS_ACCESS_KEY_ID']
      secret_access_key = Settings.aws.secret_access_key || ENV['AWS_SECRET_ACCESS_KEY']
      Aws::Credentials.new(access_key_id, secret_access_key)
    end
    Aws.config.update(credentials: @aws_credentials)
  end

  def aws_credentials?
    aws_credentials
    true
  rescue
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
    ec2 = Aws::EC2::Resource.new(region: params['region'])

    instances = ec2.create_instances(
      image_id: params['image_id'],
      min_count: params['min_count'],
      max_count: params['max_count'],
      key_name: params['key_name'],
      # security_group_ids: ['SECURITY_GROUP_ID'],
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
    ec2_wait_instances(instance_ids)
    instances.each { |i| ec2_add_tags(i, parms) }
    instances.each { |i| ec2_instance_info(i) }
    instances
  end

  def ec2_add_tags(inst, tags)
    name = tags['tag_name'] || ''
    group = tags['tag_group'] || ''
    manager = tags['tag_manager'] || ''
    service = tags['tag_service'] || ''
    inst.create_tags(
      tags: [
        { key: 'Name',  value: name },
        { key: 'Group', value: group },
        { key: 'Manager', value: manager },
        { key: 'Service', value: service }
      ]
    )
  end

  # Get all instances with tag key 'Group'
  def ec2_find_group_instances(tag_group)
    filter = { name: 'tag:Group', values: [tag_group] }
    ec2.instances(filters: [filter]).each { |i| ec2_instance_info(i) }
  end

  # Get all instances with tag key 'Group'
  def ec2_find_name_instances(tag_name)
    filter = { name: 'tag:Name', values: [tag_name] }
    ec2.instances(filters: [filter]).each { |i| ec2_instance_info(i) }
  end

  # Find an instance
  def ec2_find_instance(instance_id)
    i = ec2.instance(instance_id)
    ec2_instance_info(i)
    i
  end

  def ec2_instance_info(i)
    puts "ID:\t\t"     + i.id
    puts "Type:\t\t"   + i.instance_type
    puts "AMI ID:\t\t" + i.image_id
    puts "State:\t\t"  + i.state.name
    puts "Tags:\t\t"   + i.tags.map { |t| "#{t.key}: #{t.value}" }.join('; ')
    puts "Public IP:\t"   + i.public_ip_address
    puts "Public DNS:\t"  + i.public_dns_name
    puts "Private DNS:\t" + i.private_dns_name
    puts
    # require 'pry'
    # binding.pry
  end

  # Start an instance
  def ec2_start_instance(instance_id)
    i = ec2.instance(instance_id)
    return false if i.nil?
    return true if i.state.name == 'started'
    return true if i.state.name == 'running'
    i.start
    ec2_wait_instances([i.id])
  end

  # Stop an instance
  def ec2_stop_instance(instance_id)
    ec2 = Aws::EC2::Resource.new(region: Settings.aws.region)
    i = ec2.instance(instance_id)
    return false if i.nil?
    return true if i.state.name.include? 'stop'
    status = i.stop
    status.stopping_instances[0].current_state.name.include? 'stop'
  end

  def ec2_wait_instances(instance_ids)
    # Wait for the instance to be created, running, and passed status checks
    puts "instances #{instance_ids}: waiting to pass status checks"
    ec2.client.wait_until(:instance_status_ok, instance_ids: instance_ids)
    puts "instances #{instance_ids}: created, running, and passed status checks"
  end

end
