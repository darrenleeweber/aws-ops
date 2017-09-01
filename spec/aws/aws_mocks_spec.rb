# -*- encoding: utf-8 -*-

require 'spec_helper'

describe AwsMocks do
  IP_REGEX = /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/

  let(:aws_mocks) { described_class.new(region: REGION, service: SERVICE) }

  describe '#new' do
    it 'works' do
      expect(aws_mocks).not_to be_nil
      expect(aws_mocks).to be_an AwsMocks
    end
  end

  describe '#instances' do
    let(:instances) { aws_mocks.instances }

    it 'is an Array<Aws::EC2::Instance>' do
      expect(instances).not_to be_nil
      expect(instances).to be_an Array
      expect(instances.first).to be_an Aws::EC2::Instance
    end

    it 'is has 3 Aws::EC2::Instance, by default' do
      expect(instances.size).to be 3
    end

    it 'is can return N Aws::EC2::Instances' do
      instances = aws_mocks.instances(5)
      expect(instances.size).to be 5
    end
  end

  describe '#instance' do
    let(:inst) { aws_mocks.instance }

    it 'is an Aws::EC2::Instance' do
      expect(inst).not_to be_nil
      expect(inst).to be_an Aws::EC2::Instance
    end

    it 'has an id [String]' do
      expect(inst.id).not_to be_nil
      expect(inst.id).to be_an String
    end

    it 'has tags [Array<Aws::EC2::Types::Tag>]' do
      expect(inst.tags).not_to be_nil
      expect(inst.tags).to be_an Array
      expect(inst.tags.first).to be_an Aws::EC2::Types::Tag
    end
  end

  describe '#instance_id' do
    let(:id) { aws_mocks.instance_id }

    it 'is a String' do
      expect(id).not_to be_nil
      expect(id).to be_an String
    end

    it 'is an AWS instance ID with a hex value' do
      expect(id).to start_with 'i-0'
      expect(id).to match(/^i-0[0-9a-f]{16}$/)
    end
  end

  describe '#instance_state' do
    let(:state) { aws_mocks.instance_state }

    it 'is an Aws::EC2::Types::InstanceState' do
      expect(state).not_to be_nil
      expect(state).to be_an Aws::EC2::Types::InstanceState
    end

    it 'is "running" by default' do
      expect(state.name).to eq 'running'
    end

    it 'can be set to "stopped"' do
      state = aws_mocks.instance_state('stopped')
      expect(state.name).to eq 'stopped'
    end

    it 'can be set to "terminated"' do
      state = aws_mocks.instance_state('terminated')
      expect(state.name).to eq 'terminated'
    end
  end

  describe '#instance_tags(node = 1)' do
    let(:tags) { aws_mocks.instance_tags }
    let(:name) { tags.find { |t| t.key == 'Name' } }
    let(:group) { tags.find { |t| t.key == 'Group' } }
    let(:manager) { tags.find { |t| t.key == 'Manager' } }
    let(:service) { tags.find { |t| t.key == 'Service' } }
    let(:stage) { tags.find { |t| t.key == 'Stage' } }

    it 'is an Array<Aws::EC2::Types::Tag>' do
      expect(tags).not_to be_nil
      expect(tags).to be_an Array
      expect(tags.first).to be_an Aws::EC2::Types::Tag
    end

    it 'contains a "Name" tag' do
      expect(name).not_to be_nil
      expect(name).to be_an Aws::EC2::Types::Tag
      expect(name.key).to eq 'Name'
      expect(name.value).to be_an String
      expect(name.value).to include SERVICE
    end

    it 'contains a "Group" tag' do
      expect(group).not_to be_nil
      expect(group).to be_an Aws::EC2::Types::Tag
      expect(group.key).to eq 'Group'
      expect(group.value).to be_an String
      expect(group.value).to include SERVICE
    end

    it 'contains a "Manager" tag' do
      expect(manager).not_to be_nil
      expect(manager).to be_an Aws::EC2::Types::Tag
      expect(manager.key).to eq 'Manager'
      expect(manager.value).to be_an String
    end

    it 'contains a "Service" tag' do
      expect(service).not_to be_nil
      expect(service).to be_an Aws::EC2::Types::Tag
      expect(service.key).to eq 'Service'
      expect(service.value).to eq SERVICE
    end

    it 'contains a "Stage" tag' do
      expect(stage).not_to be_nil
      expect(stage).to be_an Aws::EC2::Types::Tag
      expect(stage.key).to eq 'Stage'
      expect(stage.value).to be_an String
      expect(stage.value).to eq 'test'
    end
  end

  describe '#placement' do
    let(:placement) { aws_mocks.placement }

    it 'is a Aws::EC2::Types::Placement' do
      expect(placement).to be_an Aws::EC2::Types::Placement
    end

    it 'is an availability zone in the REGION' do
      expect(placement.availability_zone).to match(/#{REGION}[abc]/)
    end
  end

  describe '#zone' do
    let(:zone) { aws_mocks.zone }

    it 'is a String' do
      expect(zone).to be_an String
    end

    it 'is an availability zone in the REGION' do
      expect(zone).to match(/#{REGION}[abc]/)
    end
  end

  describe '#private_dns(ip)' do
    let(:ip) { aws_mocks.random_ip }
    let(:dns) { aws_mocks.private_dns(ip) }

    it 'is a String' do
      expect(dns).to be_an String
    end

    it 'is an AWS private DNS' do
      # e.g. "ip-#{dns}.#{region}.compute.internal"
      dns_ip = ip.tr('.', '-')
      expect(dns).to start_with 'ip-'
      expect(dns).to include dns_ip
      expect(dns).to include REGION
      expect(dns).to end_with '.compute.internal'
    end
  end

  describe '#public_dns(ip)' do
    let(:ip) { aws_mocks.random_ip }
    let(:dns) { aws_mocks.public_dns(ip) }

    it 'is a String' do
      expect(dns).to be_an String
    end

    it 'is an AWS public DNS' do
      # e.g. "ec2-#{dns}.#{region}.compute.amazonaws.com"
      dns_ip = ip.tr('.', '-')
      expect(dns).to start_with 'ec2-'
      expect(dns).to include dns_ip
      expect(dns).to include REGION
      expect(dns).to end_with '.compute.amazonaws.com'
    end
  end

  describe '#random_ip' do
    let(:ip) { aws_mocks.random_ip }

    it 'is a String' do
      expect(ip).to be_an String
    end

    it 'is an IP address' do
      expect(ip).to match(IP_REGEX)
    end
  end
end

