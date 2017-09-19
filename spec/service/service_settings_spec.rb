require 'spec_helper'

RSpec.describe ServiceSettings do
  let(:service_settings) { described_class.new('zookeeper') }

  describe '#new' do
    it 'works' do
      result = ServiceSettings.new('service')
      expect(result).not_to be_nil
    end
  end

  describe '#service_keys' do
    it 'works' do
      result = service_settings.service_keys
      expect(result).not_to be_nil
    end
  end

  describe '#configuration' do
    it 'works' do
      result = service_settings.configuration
      expect(result).not_to be_nil
    end
  end

  describe '#nodes' do
    it 'works' do
      result = service_settings.nodes
      expect(result).not_to be_nil
    end
  end

  describe '#node_names' do
    it 'works' do
      result = service_settings.node_names
      expect(result).not_to be_nil
    end
  end
end

