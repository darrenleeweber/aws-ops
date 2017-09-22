require 'spec_helper'

describe ServiceManager do
  let(:service_manager) { described_class.new(SERVICE) }

  let(:nodes_various_states) do
    nodes = AWS_MOCKS.instances(6)
    RSpec::Mocks.allow_message(nodes[0], :state) { AWS_MOCKS.instance_state(0, 'pending') }
    RSpec::Mocks.allow_message(nodes[1], :state) { AWS_MOCKS.instance_state(16, 'running') }
    RSpec::Mocks.allow_message(nodes[2], :state) { AWS_MOCKS.instance_state(32, 'shutting-down') }
    RSpec::Mocks.allow_message(nodes[3], :state) { AWS_MOCKS.instance_state(48, 'terminated') }
    RSpec::Mocks.allow_message(nodes[4], :state) { AWS_MOCKS.instance_state(64, 'stopping') }
    RSpec::Mocks.allow_message(nodes[5], :state) { AWS_MOCKS.instance_state(80, 'stopped') }
    nodes
  end

  describe '#new' do
    it 'works' do
      expect(service_manager).not_to be_nil
    end
  end

  describe '#nodes' do
    context 'nodes for a service are not available' do
      before do
        allow(AwsHelpers).to receive(:ec2_find_name_instances).and_return(nil)
      end
      it 'returns an empty Array' do
        result = service_manager.nodes
        expect(result).to be_an Array
        expect(result).to be_empty
      end
    end
    context 'nodes for a service are available' do
      before do
        allow(AwsHelpers).to receive(:ec2_find_name_instances).and_return(AWS_MOCKS.instances)
      end
      it 'returns an Array<Aws::EC2::Instance>' do
        result = service_manager.nodes
        expect(result).to be_an Array
        expect(result.first).to be_an Aws::EC2::Instance
      end
      it 'each node has a tag "Service" for this service' do
        service_tags = service_manager.nodes.map { |n| n.tags.find { |t| t.key == 'Service' } }
        expect(service_tags).to be_an Array
        tags = service_tags.map(&:value).uniq
        expect(tags.count).to eq 1
        expect(tags.first).to eq SERVICE
      end
    end
  end

  context 'node state filters' do
    before do
      allow(service_manager).to receive(:nodes).and_return(nodes_various_states) if MOCK
    end

    describe '#nodes_alive' do
      let(:nodes) { service_manager.nodes_alive }
      it 'works' do
        expect(nodes).to be_an Array
        expect(nodes.first).to be_an Aws::EC2::Instance
      end
      it 'filters nodes that are terminated' do
        node_states = nodes.map { |n| n.state.name }
        expect(node_states).to include 'pending'
        expect(node_states).to include 'running'
        expect(node_states).to include 'shutting-down'
        expect(node_states).to include 'stopping'
        expect(node_states).to include 'stopped'
        expect(node_states).not_to include 'terminated'
      end
    end

    describe '#nodes_pending' do
      let(:nodes) { service_manager.nodes_pending }
      it 'works' do
        expect(nodes).to be_an Array
        expect(nodes.first).to be_an Aws::EC2::Instance
      end
      it 'selects nodes that are pending' do
        node_states = nodes.map { |n| n.state.name }
        expect(node_states).to include 'pending'
        expect(node_states).not_to include 'running'
        expect(node_states).not_to include 'shutting-down'
        expect(node_states).not_to include 'stopping'
        expect(node_states).not_to include 'stopped'
        expect(node_states).not_to include 'terminated'
      end
    end

    describe '#nodes_running' do
      let(:nodes) { service_manager.nodes_running }
      it 'works' do
        expect(nodes).to be_an Array
        expect(nodes.first).to be_an Aws::EC2::Instance
      end
      it 'selects nodes that are running' do
        node_states = nodes.map { |n| n.state.name }
        expect(node_states).to include 'running'
        expect(node_states).not_to include 'pending'
        expect(node_states).not_to include 'shutting-down'
        expect(node_states).not_to include 'stopping'
        expect(node_states).not_to include 'stopped'
        expect(node_states).not_to include 'terminated'
      end
    end

    describe '#nodes_shutting_down' do
      let(:nodes) { service_manager.nodes_shutting_down }
      it 'works' do
        expect(nodes).to be_an Array
        expect(nodes.first).to be_an Aws::EC2::Instance
      end
      it 'selects nodes that are shutting_down' do
        node_states = nodes.map { |n| n.state.name }
        expect(node_states).to include 'shutting-down'
        expect(node_states).not_to include 'pending'
        expect(node_states).not_to include 'running'
        expect(node_states).not_to include 'stopped'
        expect(node_states).not_to include 'stopping'
        expect(node_states).not_to include 'terminated'
      end
    end

    describe '#nodes_stopped' do
      let(:nodes) { service_manager.nodes_stopped }
      it 'works' do
        expect(nodes).to be_an Array
        expect(nodes.first).to be_an Aws::EC2::Instance
      end
      it 'selects nodes that are stopped' do
        node_states = nodes.map { |n| n.state.name }
        expect(node_states).to include 'stopped'
        expect(node_states).not_to include 'pending'
        expect(node_states).not_to include 'running'
        expect(node_states).not_to include 'shutting-down'
        expect(node_states).not_to include 'stopping'
        expect(node_states).not_to include 'terminated'
      end
    end

    describe '#nodes_stopping' do
      let(:nodes) { service_manager.nodes_stopping }
      it 'works' do
        expect(nodes).to be_an Array
        expect(nodes.first).to be_an Aws::EC2::Instance
      end
      it 'selects nodes that are stopping' do
        node_states = nodes.map { |n| n.state.name }
        expect(node_states).to include 'stopping'
        expect(node_states).not_to include 'pending'
        expect(node_states).not_to include 'running'
        expect(node_states).not_to include 'shutting-down'
        expect(node_states).not_to include 'stopped'
        expect(node_states).not_to include 'terminated'
      end
    end

    describe '#nodes_terminated' do
      let(:nodes) { service_manager.nodes_terminated }
      it 'works' do
        expect(nodes).to be_an Array
        expect(nodes.first).to be_an Aws::EC2::Instance
      end
      it 'selects nodes that are terminated' do
        node_states = nodes.map { |n| n.state.name }
        expect(node_states).to include 'terminated'
        expect(node_states).not_to include 'pending'
        expect(node_states).not_to include 'running'
        expect(node_states).not_to include 'shutting-down'
        expect(node_states).not_to include 'stopping'
        expect(node_states).not_to include 'stopped'
      end
    end
  end

  describe '#node_names' do
    before do
      allow(service_manager).to receive(:nodes).and_return(nodes_various_states) if MOCK
    end
    let(:node_names) { service_manager.node_names }
    it 'works' do
      result = service_manager.node_names
      expect(result).to be_an Array
      expect(result.first).to be_an String
    end
  end

  describe '#node_name' do
    let(:node) { nodes_various_states.first }
    it 'works' do
      result = service_manager.node_name(node)
      expect(result).to be_an String
    end
  end

  describe '#node_config' do
    let(:node) { nodes_various_states.first }
    let(:node_name) { service_manager.node_name(node) }
    it 'works' do
      config = service_manager.node_config(node)
      expect(config).to be_an Config::Options
      expect(config.tag_name).to eq node_name
    end
  end

  describe '#find_node_by_name' do
    before do
      allow(service_manager).to receive(:nodes).and_return(nodes_various_states) if MOCK
    end
    let(:node_names) { service_manager.node_names.reject { |n| n == 'test_zookeeper4' } }
    it 'works' do
      node_name = node_names.sample
      result = service_manager.find_node_by_name(node_name)
      expect(result).to be_an Aws::EC2::Instance
    end
    it 'returns nil when node is terminated' do
      result = service_manager.find_node_by_name('test_zookeeper4')
      expect(result).to be_nil
    end
    it 'returns nil when node name does not exist' do
      result = service_manager.find_node_by_name('missing')
      expect(result).to be_nil
    end
  end

  describe '#describe_nodes' do
    before do
      allow(service_manager).to receive(:nodes).and_return(nodes_various_states) if MOCK
    end
    it 'works' do
      result = service_manager.describe_nodes
      expect(result).to be_an Array
      expect(result.first).to be_an String
    end
  end

  describe '#etc_hosts' do
    # Most of this functionality is tested in spec/aws/aws_helpers_spec.rb
    let(:node) { nodes_various_states.first }
    let(:node_name) { service_manager.node_name(node) }
    before do
      allow(service_manager).to receive(:nodes).and_return([node]) if MOCK
    end
    it 'returns public IPs associated with a host alias' do
      result = service_manager.etc_hosts
      expect(result).to be_an Array
      expect(result.first).to be_an String
      expect(result.first).to include node.public_ip_address
      expect(result.first).to include node_name
    end
  end

  describe '#ssh_config' do
    # Most of this functionality is tested in spec/aws/aws_helpers_spec.rb
    let(:node) { nodes_various_states.first }
    let(:node_name) { service_manager.node_name(node) }
    let(:node_config) { service_manager.settings.find_by_name(node_name) }
    before do
      allow(service_manager).to receive(:nodes).and_return([node]) if MOCK
    end
    it 'returns a host alias and user associated with a public DNS' do
      result = service_manager.ssh_config
      expect(result).to be_an Array
      expect(result.first).to be_an String
      expect(result.first).to include node.public_dns_name
      expect(result.first).to include node_config.tag_name
      expect(result.first).to include node_config.user
    end
  end

  context 'create nodes' do
    let(:config) { service_manager.settings.nodes.first }

    context 'when no nodes exist' do
      before do
        if MOCK
          allow(service_manager).to receive(:nodes).and_return([])
          expect(AwsHelpers).to receive(:ec2_create).and_return(nil)
        end
      end
      describe '#create_nodes' do
        it 'works' do
          service_manager.create_nodes
        end
      end
      describe '#create_node' do
        it 'works' do
          service_manager.create_node(config)
        end
      end
    end

    context 'when nodes exist' do
      before do
        if MOCK
          allow(service_manager).to receive(:nodes).and_return(nodes_various_states)
          expect(AwsHelpers).not_to receive(:ec2_create)
        end
      end
      describe '#create_nodes' do
        it 'works' do
          service_manager.create_nodes
        end
      end
      describe '#create_node' do
        it 'works' do
          service_manager.create_node(config)
        end
      end
    end
  end

  context 'reboot nodes' do
    context 'when no nodes exist' do
      before do
        if MOCK
          allow(service_manager).to receive(:nodes).and_return([])
          # CANNOT USE THIS EXPECTATION BECAUSE IT LEAKS OUT ACROSS CONTEXTS
          # expect(AwsHelpers).not_to receive(:ec2_reboot_instance)
        end
      end
      describe '#reboot_nodes' do
        it 'works' do
          service_manager.reboot_nodes
        end
      end
    end

    context 'when nodes exist' do
      before do
        if MOCK
          allow(service_manager).to receive(:nodes).and_return(nodes_various_states)
          allow(AwsHelpers).to receive(:ec2_wait_instance_startup).and_return(nil)
          expect(AwsHelpers).to receive(:ec2_reboot_instance)
        end
      end
      describe '#reboot_nodes' do
        it 'works' do
          service_manager.reboot_nodes
        end
      end
    end
  end

  context 'reboot node' do
    let(:config) { service_manager.settings.nodes.first }
    context 'when no nodes exist' do
      before do
        if MOCK
          allow(service_manager).to receive(:nodes).and_return([])
          # CANNOT USE THIS EXPECTATION BECAUSE IT LEAKS OUT ACROSS CONTEXTS
          # expect(AwsHelpers).not_to receive(:ec2_reboot_instance)
        end
      end
      describe '#reboot_node' do
        it 'works' do
          service_manager.reboot_node(config)
        end
      end
    end
    context 'when nodes exist' do
      before do
        if MOCK
          allow(service_manager).to receive(:nodes).and_return(nodes_various_states)
          expect(AwsHelpers).to receive(:ec2_reboot_instance)
        end
      end
      describe '#reboot_node' do
        it 'works' do
          service_manager.reboot_node(config)
        end
      end
    end
  end

  context 'stop node' do
    let(:config) { service_manager.settings.nodes.first }

    context 'when no nodes exist' do
      before do
        allow(service_manager).to receive(:nodes).and_return([]) if MOCK
        # CANNOT USE THIS EXPECTATION BECAUSE IT LEAKS OUT ACROSS CONTEXTS
        # expect(AwsHelpers).not_to receive(:ec2_stop_instance)
      end
      describe '#stop_node' do
        it 'works' do
          service_manager.stop_node(config)
        end
      end
    end

    context 'when nodes exist' do
      before do
        allow(service_manager).to receive(:nodes).and_return(nodes_various_states) if MOCK
        expect(AwsHelpers).to receive(:ec2_stop_instance).and_return(nil)
      end
      describe '#stop_node' do
        it 'works' do
          service_manager.stop_node(config)
        end
      end
    end
  end

  context 'stop nodes' do
    context 'when no nodes exist' do
      before do
        if MOCK
          allow(service_manager).to receive(:nodes).and_return([])
          # CANNOT USE THIS EXPECTATION BECAUSE IT LEAKS OUT ACROSS CONTEXTS
          # expect(AwsHelpers).not_to receive(:ec2_stop_instance)
        end
      end
      describe '#stop_nodes' do
        it 'works' do
          service_manager.stop_nodes
        end
      end
    end

    context 'when nodes exist' do
      before do
        if MOCK
          allow(service_manager).to receive(:nodes).and_return(nodes_various_states)
          expect(AwsHelpers).to receive(:ec2_stop_instance)
        end
      end
      describe '#stop_nodes' do
        it 'works' do
          service_manager.stop_nodes
        end
      end
    end
  end

  context 'terminate nodes' do
    let(:nodes) { service_manager.nodes_running }
    let(:node) { nodes.first }
    let(:config) { service_manager.settings.nodes.first }

    context 'confirmed' do
      before do
        if MOCK
          allow(service_manager).to receive(:nodes).and_return(nodes_various_states)
          allow(service_manager).to receive(:confirmation?).and_return(true)
          allow(AwsHelpers).to receive(:ec2_wait_instance_terminated).and_return(nil)
        end
      end
      describe '#terminate_nodes' do
        it 'works' do
          expect(AwsHelpers).to receive(:ec2_terminate_instance).and_call_original
          service_manager.terminate_nodes
        end
      end
      describe '#terminate_node' do
        it 'works' do
          expect(AwsHelpers).to receive(:ec2_terminate_instance).and_call_original
          service_manager.terminate_node(config)
        end
      end
    end

    context 'averted' do
      before do
        if MOCK
          allow(service_manager).to receive(:nodes).and_return(nodes_various_states)
          allow(service_manager).to receive(:confirmation?).and_return(false)
          expect(AwsHelpers).not_to receive(:ec2_terminate_instance)
        end
      end
      describe '#terminate_nodes' do
        it 'works' do
          service_manager.terminate_nodes
        end
      end
      describe '#terminate_node' do
        it 'works' do
          service_manager.terminate_node(config)
        end
      end
    end

    context 'nothing to do' do
      before do
        if MOCK
          allow(service_manager).to receive(:nodes).and_return([])
          expect(service_manager).not_to receive(:confirmation?)
          expect(AwsHelpers).not_to receive(:ec2_terminate_instance)
        end
      end
      describe '#terminate_nodes' do
        it 'works' do
          result = service_manager.terminate_nodes
          expect(result).to be_nil
        end
      end
      describe '#terminate_node' do
        it 'works' do
          allow(config).to receive(:tag_name).and_return('missing')
          result = service_manager.terminate_node(config)
          expect(result).to be_nil
        end
      end
    end

    describe '#confirmation?' do
      require 'highline/import'
      let(:cli) { HighLine.new }
      before do
        allow(HighLine).to receive(:new).and_return(cli)
      end
      it 'returns true when user responds "y"' do
        allow(cli).to receive(:ask).and_return('y')
        expect(service_manager.send(:confirmation?, 'whatever')).to be true
      end
      it 'returns false when user responds "n"' do
        allow(cli).to receive(:ask).and_return('n')
        expect(service_manager.send(:confirmation?, 'whatever')).to be false
      end
    end
  end
end

