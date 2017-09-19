# -*- encoding: utf-8 -*-

require 'spec_helper'

describe KafkaHelpers do
  let(:kafka_helpers) { KafkaHelpers }

  let(:aws_mocks) { AwsMocks.new(region: REGION, service: service) }

  let(:service_config) { kafka_helpers.configuration }

  let(:service_manager) { ServiceManager.new service }

  let(:service) { 'kafka' }

  before do
    if MOCK
      allow(service_manager).to receive(:nodes).and_return(aws_mocks.instances)
      allow(kafka_helpers).to receive(:manager).and_return(service_manager)
    end
  end

  describe '#settings' do
    it 'is a ServiceSettings' do
      expect(kafka_helpers.settings).to be_an ServiceSettings
    end
    it 'has settings for Kafka' do
      expect(kafka_helpers.settings.service).to eq service
    end
  end

  describe '#manager' do
    before do
      allow(kafka_helpers).to receive(:manager).and_call_original
    end
    it 'is a ServiceManager' do
      expect(kafka_helpers.manager).to be_an ServiceManager
    end
    it 'can manage Kafka' do
      expect(kafka_helpers.manager.service).to eq service
    end
  end

  describe '#configuration' do
    it 'is a Config::Options' do
      expect(kafka_helpers.configuration).to be_an Config::Options
    end

    it 'has options for Kafka' do
      expect(kafka_helpers.configuration.keys).to include :kafka_home
    end
  end

  describe '#brokers' do
    let(:brokers) { kafka_helpers.brokers }
    it 'is a String' do
      expect(brokers).to be_an String
    end
    it 'has brokers for private-dns:port' do
      brokers = kafka_helpers.brokers(false)
      expect(brokers).to match(/compute.internal:9092/)
    end
    it 'has brokers for public-dns:port (default)' do
      expect(brokers).to match(/amazonaws.com:9092/)
    end
  end

  describe '#kafka_home' do
    it 'is a configuration parameter' do
      expect(kafka_helpers.kafka_home).to eq service_config['kafka_home']
    end
  end

  describe '#kafka_heap_opts' do
    it 'is a configuration parameter' do
      expect(kafka_helpers.kafka_heap_opts).to eq service_config['kafka_heap_opts']
    end
  end

  describe '#kafka_ver' do
    # this value is space separated params for the kafka install script(s)
    it 'combines scala and kafka versions' do
      ver = kafka_helpers.kafka_ver
      expect(ver).to include service_config['kafka_version']
      expect(ver).to include service_config['scala_version']
    end
  end

  describe '#listeners' do
    let(:listeners) { kafka_helpers.listeners }
    it 'is a Hash' do
      expect(listeners).to be_an Hash
    end
    it 'has a key for each hostname' do
      keys = listeners.keys
      expect(keys).to include 'test_kafka1'
    end
    it 'has values for private-dns:port' do
      values = listeners.values
      expect(values.first).to match(/compute.internal:9092/)
    end
    # TODO: there is a private DNS for an instance that is stopped
  end

  describe '#advertised_listeners' do
    let(:advertised_listeners) { kafka_helpers.advertised_listeners }
    it 'is a Hash' do
      expect(advertised_listeners).to be_an Hash
    end
    it 'has a key for each hostname' do
      keys = advertised_listeners.keys
      expect(keys).to include 'test_kafka1'
    end
    it 'has values for public-dns:port' do
      values = advertised_listeners.values
      expect(values.first).to match(/amazonaws.com:9092/)
    end
    # TODO: there is no public DNS for an instance that is stopped
  end
end

