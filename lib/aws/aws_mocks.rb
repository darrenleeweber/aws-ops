# -*- encoding: utf-8 -*-

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

  # the config/settings/test.yml settings contains 'zookeeper' services

  def initialize(region: 'us-west-2', service: 'zookeeper')
    @region = region
    @service = service
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
    RSpec::Mocks.allow_message(inst, :launch_time) { Time.now.utc }
    RSpec::Mocks.allow_message(inst, :tags) { instance_tags(n) }
    RSpec::Mocks.allow_message(inst, :placement) { placement }
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

  def instance_state(state = 'running')
    Aws::EC2::Types::InstanceState.new(name: state)
  end

  def instance_tags(node = 1)
    [
      Aws::EC2::Types::Tag.new(key: 'Name', value: "test_#{service}#{node}"),
      Aws::EC2::Types::Tag.new(key: 'Group', value: "test_#{service}"),
      Aws::EC2::Types::Tag.new(key: 'Stage', value: 'test'),
      Aws::EC2::Types::Tag.new(key: 'Manager', value: 'AManager'),
      Aws::EC2::Types::Tag.new(key: 'Service', value: service)
    ]
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

