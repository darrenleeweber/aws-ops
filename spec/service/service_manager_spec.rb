require 'spec_helper'

describe ServiceManager do
  let(:service_manager) { described_class.new(SERVICE) }

  describe '#new' do
    it 'works' do
      service = double('service')
      result = ServiceManager.new(service)
      expect(result).not_to be_nil
    end
  end

  describe '#nodes' do
    context 'nodes for a service are not available' do
      it 'returns an empty Array' do
        result = service_manager.nodes
        expect(result).to be_an Array
        expect(result).to be_empty
      end
    end
    context 'nodes for a service are available' do
      before do
        allow(service_manager).to receive(:nodes).and_return(AWS_MOCKS.instances) if MOCK
      end
      it 'returns an Array<Aws::EC2::Instance>' do
        result = service_manager.nodes
        expect(result).to be_an Array
        expect(result.first).to be_an Aws::EC2::Instance
      end
      xit 'each node has a tag "Service" for this service' do
        result = service_manager.nodes
        expect(result).to be_an Array
        expect(result.first).to be_an Aws::EC2::Instance
      end
    end
  end

  # TODO: auto-generated
  describe '#nodes_alive' do
    # TODO: add some mock instance state data for 'terminated' instances
    xit 'works' do
      result = service_manager.nodes_alive
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#nodes_stopped' do
    # TODO: add some mock instance state data for 'stopped' instances
    xit 'works' do
      result = service_manager.nodes_stopped
      expect(result).not_to be_nil
    end
  end

  describe '#nodes_running' do
    # TODO: add some mock instance state data for 'terminated' instances
    xit 'works' do
      result = service_manager.nodes_running
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#nodes_terminated' do
    # TODO: add some mock instance state data for 'terminated' instances
    xit 'works' do
      result = service_manager.nodes_terminated
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#node_names' do
    # TODO: add some mock instance tag "Name" data
    it 'works' do
      result = service_manager.node_names
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#find_node_by_name' do
    # TODO: add some mock instance tag "Name" data and search for it
    xit 'works' do
      result = service_manager.find_node_by_name('test_zookeeper1')
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#describe_nodes' do
    it 'works' do
      result = service_manager.describe_nodes
      expect(result).not_to be_nil
      # result is an empty Array
    end
  end

  # TODO: auto-generated
  describe '#etc_hosts' do
    # TODO: add some mock instance data for public/private IPs
    xit 'returns public IPs' do
      public = true
      result = service_manager.etc_hosts(public)
      expect(result).not_to be_nil
    end
    xit 'returns private IPs' do
      public = false
      result = service_manager.etc_hosts(public)
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#ssh_config' do
    # TODO: add some mock instance data for public/private DNSs
    xit 'returns public hosts' do
      public = true
      result = service_manager.ssh_config(public)
      expect(result).not_to be_nil
    end
    xit 'returns private hosts' do
      public = false
      result = service_manager.ssh_config(public)
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#create_nodes' do
    xit 'works' do
      result = service_manager.create_nodes
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#create_node' do
    xit 'works' do
      params = double('params')
      result = service_manager.create_node(params)
      expect(result).not_to be_nil
    end
  end

  # Aws::EC2::Errors::IncorrectState:
  #   Cannot reboot instance i-038f22b942262bc18 that is currently in stopped state.

  # TODO: auto-generated
  describe '#reboot_node' do
    xit 'works' do
      params = double('params')
      result = service_manager.reboot_node(params)
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#reboot_nodes' do
    xit 'works' do
      result = service_manager.reboot_nodes
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#terminate_nodes' do
    xit 'works' do
      result = service_manager.terminate_nodes
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#terminate_node' do
    xit 'works' do
      params = double('params')
      result = service_manager.terminate_node(params)
      expect(result).not_to be_nil
    end
  end
end

