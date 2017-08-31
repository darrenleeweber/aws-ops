# -*- encoding: utf-8 -*-

require 'spec_helper'

RSpec.describe ServiceSettings do

  let(:service_settings) { described_class.new('zookeeper') }

  # TODO: auto-generated
  describe '#new' do
    it 'works' do
      result = ServiceSettings.new('service')
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#service_keys' do
    it 'works' do
      result = service_settings.service_keys
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#nodes' do
    it 'works' do
      result = service_settings.nodes
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#node_names' do
    it 'works' do
      result = service_settings.node_names
      expect(result).not_to be_nil
    end
  end

end
