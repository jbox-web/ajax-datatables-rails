require 'spec_helper'

describe 'AjaxDatatablesRails::ORM::ActiveRecord#fetch_records' do
  context 'Private API' do
    let(:view) { double('view', params: sample_params) }
    let(:datatable) { SampleDatatable.new(view) }

    before(:each) do
      AjaxDatatablesRails.configure do |config|
        config.db_adapter = :sqlite
        config.orm = :active_record
      end

      User.create(username: 'johndoe', email: 'johndoe@example.com')
      User.create(username: 'msmith', email: 'mary.smith@example.com')
    end

    after(:each) do
      User.destroy_all
    end

    describe 'fetch records' do
      it 'calls #get_raw_records' do
        expect(datatable).to receive(:get_raw_records) { User.all }
        datatable.send(:fetch_records)
      end

      it 'returns a collection of records' do
        expect(datatable).to receive(:get_raw_records) { User.all }
        expect(datatable.send(:fetch_records)).to be_a(ActiveRecord::Relation)
      end
    end
  end
end
