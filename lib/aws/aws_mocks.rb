require 'aws-sdk-ec2'
require 'rspec'

# Mocks for AWS EC2 resources
# http://docs.aws.amazon.com/sdk-for-ruby/v2/developer-guide/stubbing.html
class AwsMocks

  include RSpec::Mocks
  RSpec::Mocks.setup

  attr_reader :region
  attr_reader :resource
  attr_reader :service
  attr_reader :stage

  # the config/settings/test.yml settings contains 'zookeeper' services

  def initialize(region: 'us-west-2', service: 'zookeeper', stage: 'test')
    @region = region
    @service = service
    @stage = stage
    @resource = Aws::EC2::Resource.new(region: region, stub_responses: true)
  end

  def instances(node_count = 3)
    [*1..node_count].map { |i| instance(i) }
  end

  def instance(n = 1)
    inst = Aws::EC2::Instance.new(
      id: instance_id,
      stub_responses: true
    )
    RSpec::Mocks.allow_message(inst, :instance_type) { 't2.micro' }
    RSpec::Mocks.allow_message(inst, :image_id) { 'ami-6e1a0117' }
    RSpec::Mocks.allow_message(inst, :key_name) { 'key-pair' }
    RSpec::Mocks.allow_message(inst, :launch_time) { Time.now.utc }
    RSpec::Mocks.allow_message(inst, :tags) { instance_tags(n) }
    RSpec::Mocks.allow_message(inst, :placement) { placement }
    RSpec::Mocks.allow_message(inst, :state) { instance_state }
    ip_public = random_ip
    ip_private = random_ip
    RSpec::Mocks.allow_message(inst, :private_ip_address) { ip_private }
    RSpec::Mocks.allow_message(inst, :private_dns_name) { private_dns(ip_private) }
    RSpec::Mocks.allow_message(inst, :public_ip_address) { ip_public }
    RSpec::Mocks.allow_message(inst, :public_dns_name) { public_dns(ip_public) }
    inst
  end

  def instance_id
    'i-0' + SecureRandom.hex(8)
  end

  # http://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/EC2/Types/InstanceState.html
  #  0: pending
  # 16: running
  # 32: shutting-down
  # 48: terminated
  # 64: stopping
  # 80: stopped
  def instance_state(code = 16, name = 'running')
    Aws::EC2::Types::InstanceState.new(code: code, name: name)
  end

  def instance_tags(node = 1)
    [
      Aws::EC2::Types::Tag.new(key: 'Name', value: instance_tag_name(node)),
      Aws::EC2::Types::Tag.new(key: 'Group', value: instance_tag_group),
      Aws::EC2::Types::Tag.new(key: 'Stage', value: stage),
      Aws::EC2::Types::Tag.new(key: 'Manager', value: 'AManager'),
      Aws::EC2::Types::Tag.new(key: 'Service', value: service)
    ]
  end

  def instance_tag_name(node = 1)
    "#{stage}_#{service}#{node}"
  end

  def instance_tag_group
    "#{stage}_#{service}"
  end

  def placement
    Aws::EC2::Types::Placement.new(availability_zone: zone, tenancy: 'default')
  end

  def private_dns(ip)
    dns = ip.tr('.', '-')
    "ip-#{dns}.#{region}.compute.internal"
  end

  def public_dns(ip)
    dns = ip.tr('.', '-')
    "ec2-#{dns}.#{region}.compute.amazonaws.com"
  end

  def random_ip
    [*0..255].sample(4).join('.')
  end

  def zone
    region + %w[a b c].sample
  end

end

