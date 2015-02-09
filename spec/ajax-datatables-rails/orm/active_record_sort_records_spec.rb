require 'spec_helper'

describe 'AjaxDatatablesRails::ORM::ActiveRecord#sort_records' do
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

  describe 'sort records' do
    let(:records) { User.all }

    it 'returns a records collection sorted by :order params' do
      # set to order Users by email in descending order
      datatable.params[:order]['0'] = { column: '1', dir: 'desc' }
      expect(datatable.send(:sort_records, records).map(&:email)).to match(
        ['mary.smith@example.com', 'johndoe@example.com']
      )
    end

    it 'can handle multiple sorting columns' do
      # set to order by Users username in ascending order, and
      # by Users email in descending order
      datatable.params[:order]['0'] = { column: '0', dir: 'asc' }
      datatable.params[:order]['1'] = { column: '1', dir: 'desc' }
      params = datatable.params
      expect(datatable.send(:sort_records, records).to_sql).to eq(
        "SELECT \"users\".* FROM \"users\"  ORDER BY users.username ASC, users.email DESC"
      )
    end

    describe '#sort_column helper method' do
      before(:each) do
        datatable.params[:order]['0'] = { column: '0', dir: 'asc' }
        datatable.params[:order]['1'] = { column: '1', dir: 'desc' }
      end

      it 'returns a string representing the column(s) to sort by' do
        params = datatable.params
        expect(datatable.send(:sort_column, params[:order]['0'])).to eq("users.username")
        expect(datatable.send(:sort_column, params[:order]['1'])).to eq("users.email")
      end
    end

    describe '#sort_direction helper method' do
      let(:params) { datatable.params }

      it 'matches value of params[:order]' do
        expect(datatable.send(:sort_direction, params[:order]["0"])).to eq('ASC')

        params[:order]['0'][:dir] = 'desc'
        expect(datatable.send(:sort_direction, params[:order]['0'])).to eq('DESC')
      end

      it 'can only be one option from ASC or DESC' do
        params[:order]['0'][:dir] = 'foo'
        expect(datatable.send(:sort_direction, params[:order]["0"])).to eq('ASC')
      end
    end
  end
end
