require 'spec_helper'

describe AjaxDatatablesRails::ORM::ActiveRecord do
  context 'Private API' do
    let(:datatable) { ComplexDatatable.new(sample_params) }

    before(:each) do
      create(:user, username: 'johndoe', email: 'johndoe@example.com')
      create(:user, username: 'msmith', email: 'mary.smith@example.com')
    end

    describe '#fetch_records' do
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
