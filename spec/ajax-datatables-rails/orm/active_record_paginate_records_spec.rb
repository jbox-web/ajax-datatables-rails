require 'spec_helper'

describe 'AjaxDatatablesRails::ORM::ActiveRecord#paginate_records' do
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

  describe 'paginate records' do
    let(:records) { User.all }

    it 'requires a records collection argument' do
      expect { datatable.send(:paginate_records) }.to raise_error
    end

    it 'paginates records properly' do
      expect(datatable.send(:paginate_records, records).to_sql).to include(
        "LIMIT 10 OFFSET 0"
      )

      datatable.params[:start] = "26"
      datatable.params[:length] = "25"
      expect(datatable.send(:paginate_records, records).to_sql).to include(
        "LIMIT 25 OFFSET 25"
      )
    end

    it 'depends on the value of #offset' do
      expect(datatable.datatable).to receive(:offset)
      datatable.send(:paginate_records, records)
    end

    it 'depends on the value of #per_page' do
      expect(datatable.datatable).to receive(:per_page).at_least(:once) { 10 }
      datatable.send(:paginate_records, records)
    end
  end
end

