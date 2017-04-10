require 'spec_helper'

describe AjaxDatatablesRails::ORM::ActiveRecord do
  let(:view) { double('view', params: sample_params) }
  let(:datatable) { ComplexDatatable.new(view) }

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

  describe '#sort_records' do
    let(:records) { User.all }

    it 'returns a records collection sorted by :order params' do
      # set to order Users by email in descending order
      datatable.params[:order]['0'] = { column: '1', dir: 'desc' }
      expect(datatable.sort_records(records).map(&:email)).to match(
        ['mary.smith@example.com', 'johndoe@example.com']
      )
    end

    it 'can handle multiple sorting columns' do
      # set to order by Users username in ascending order, and
      # by Users email in descending order
      datatable.params[:order]['0'] = { column: '0', dir: 'asc' }
      datatable.params[:order]['1'] = { column: '1', dir: 'desc' }
      expect(datatable.sort_records(records).to_sql).to include(
        "ORDER BY users.username ASC, users.email DESC"
      )
    end
  end
end
