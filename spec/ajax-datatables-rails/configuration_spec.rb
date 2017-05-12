require 'spec_helper'

describe AjaxDatatablesRails do
  describe 'configurations' do
    context 'configurable from outside' do
      before(:each) do
        AjaxDatatablesRails.configure do |config|
          config.db_adapter = :mysql
        end
      end

      it 'should have custom value' do
        expect(AjaxDatatablesRails.config.db_adapter).to eq(:mysql)
      end
    end
  end
end

describe AjaxDatatablesRails::Configuration do
  let(:config) { AjaxDatatablesRails::Configuration.new }

  describe 'default config' do
    it 'default orm should :active_record' do
      expect(config.orm).to eq(:active_record)
    end

    it 'default db_adapter should :postgresql' do
      expect(config.db_adapter).to eq(:postgresql)
    end
  end

  describe 'custom config' do
    it 'should accept db_adapter custom value' do
      config.db_adapter = :mysql
      expect(config.db_adapter).to eq(:mysql)
    end

    it 'accepts a custom orm value' do
      config.orm = :mongoid
      expect(config.orm).to eq(:mongoid)
    end
  end
end
