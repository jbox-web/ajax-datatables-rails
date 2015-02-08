require 'spec_helper'

describe AjaxDatatablesRails do
  describe "configurations" do
    context "configurable from outside" do
      before(:each) do
        AjaxDatatablesRails.configure do |config|
          config.db_adapter = :mysql
        end
      end

      it "should have custom value" do
        expect(AjaxDatatablesRails.config.db_adapter).to eq(:mysql)
      end
    end
  end
end

describe AjaxDatatablesRails::Configuration do
  let(:config) { AjaxDatatablesRails::Configuration.new }

  describe "default config" do
    it "default orm should :active_record" do
      expect(config.orm).to eq(:active_record)
    end

    it "default db_adapter should :pg (postgresql)" do
      expect(config.db_adapter).to eq(:pg)
    end
  end

  describe "custom config" do
    it 'should accept db_adapter custom value' do
      config.db_adapter = :mysql
      expect(config.db_adapter).to eq(:mysql)
    end

    it 'accepts a custom orm value' do
      config.orm = :mongoid
      expect(config.orm).to eq(:mongoid)
    end
  end

  describe '#typecast' do
    let(:view) { double('view', :params => sample_params) }
    let(:datatable) { AjaxDatatablesRails::Base.new(view) }

    it 'returns VARCHAR if :db_adapter is :pg' do
      allow_any_instance_of(AjaxDatatablesRails::Configuration).to receive(:db_adapter) { :pg }
      expect(datatable.send(:typecast)).to eq('VARCHAR')
    end

    it 'returns CHAR if :db_adapter is :mysql2' do
      allow_any_instance_of(AjaxDatatablesRails::Configuration).to receive(:db_adapter) { :mysql }
      expect(datatable.send(:typecast)).to eq('CHAR')
    end

    it 'returns TEXT if :db_adapter is :sqlite3' do
      allow_any_instance_of(AjaxDatatablesRails::Configuration).to receive(:db_adapter) { :sqlite }
      expect(datatable.send(:typecast)).to eq('TEXT')
    end
  end
end

