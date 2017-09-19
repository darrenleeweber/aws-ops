# -*- encoding: utf-8 -*-

require 'spec_helper'

describe ZookeeperHelpers do
  let(:zookeeper_helpers) { ZookeeperHelpers }

  let(:aws_mocks) { AwsMocks.new(region: REGION, service: service) }

  let(:service_config) { zookeeper_helpers.configuration }

  let(:service_manager) { ServiceManager.new service }

  let(:service) { 'zookeeper' }

  before do
    if MOCK
      allow(service_manager).to receive(:nodes).and_return(aws_mocks.instances)
      allow(zookeeper_helpers).to receive(:manager).and_return(service_manager)
    end
  end

  describe '#settings' do
    it 'is a ServiceSettings' do
      expect(zookeeper_helpers.settings).to be_an ServiceSettings
    end
    it 'has settings for Zookeeper' do
      expect(zookeeper_helpers.settings.service).to eq service
    end
  end

  describe '#manager' do
    before do
      allow(zookeeper_helpers).to receive(:manager).and_call_original
    end
    it 'is a ServiceManager' do
      expect(zookeeper_helpers.manager).to be_an ServiceManager
    end
    it 'can manage Zookeeper' do
      expect(zookeeper_helpers.manager.service).to eq service
    end
  end

  describe '#configuration' do
    it 'is a Config::Options' do
      expect(zookeeper_helpers.configuration).to be_an Config::Options
    end

    it 'has options for Zookeeper' do
      expect(zookeeper_helpers.configuration.keys).to include :client_port
    end
  end

  describe '#connections' do
    let(:connections) { zookeeper_helpers.connections }
    let(:client_port) { zookeeper_helpers.configuration['client_port'] }
    it 'is an Array<String>' do
      expect(connections).to be_an Array
      expect(connections.first).to be_an String
    end
    it 'has connections for private-dns:port' do
      connections = zookeeper_helpers.connections(false)
      expect(connections.first).to match(/compute.internal:#{client_port}/)
    end
    it 'has connections for public-dns:port (default)' do
      expect(connections.first).to match(/amazonaws.com:#{client_port}/)
    end
  end

  describe '#zoo_cfg' do
    let(:zoo_cfg) { zookeeper_helpers.zoo_cfg }
    let(:leader_port) { zookeeper_helpers.configuration['leader_port'] }
    let(:election_port) { zookeeper_helpers.configuration['election_port'] }

    it 'is an Array<String>' do
      expect(zoo_cfg).to be_an Array
      expect(zoo_cfg.first).to be_an String
    end
    it 'has zoo_cfg for private-dns:port (default)' do
      zoo_cfg = zookeeper_helpers.zoo_cfg
      expect(zoo_cfg.first).to match(/compute.internal:#{leader_port}:#{election_port}/)
    end
    it 'has zoo_cfg for public-dns:port' do
      zoo_cfg = zookeeper_helpers.zoo_cfg(true)
      expect(zoo_cfg.first).to match(/amazonaws.com:#{leader_port}:#{election_port}/)
    end
  end
end

