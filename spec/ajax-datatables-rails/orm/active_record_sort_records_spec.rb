require 'spec_helper'

describe AjaxDatatablesRails::ORM::ActiveRecord do

  let(:datatable) { ComplexDatatable.new(sample_params) }
  let(:nulls_last_datatable) { DatatableOrderNullsLast.new(sample_params) }
  let(:records) { User.all }

  before(:each) do
    create(:user, username: 'johndoe', email: 'johndoe@example.com')
    create(:user, username: 'msmith', email: 'mary.smith@example.com')
  end

  describe '#sort_records' do
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
        'ORDER BY users.username ASC, users.email DESC'
      )
    end

    it 'should not sort a column which is not orderable' do
      datatable.params[:order]['0'] = { column: '0', dir: 'asc' }
      datatable.params[:order]['1'] = { column: '4', dir: 'desc' }

      expect(datatable.sort_records(records).to_sql).to include(
        'ORDER BY users.username ASC'
      )

      expect(datatable.sort_records(records).to_sql).to_not include(
        'users.post_id DESC'
      )
    end
  end

  describe '#sort_records with nulls last using global config' do
    before { AjaxDatatablesRails.config.nulls_last = true }
    after  { AjaxDatatablesRails.config.nulls_last = false }

    it 'can handle multiple sorting columns' do
      # set to order by Users username in ascending order, and
      # by Users email in descending order
      datatable.params[:order]['0'] = { column: '0', dir: 'asc' }
      datatable.params[:order]['1'] = { column: '1', dir: 'desc' }
      expect(datatable.sort_records(records).to_sql).to include(
        'ORDER BY CASE WHEN users.username IS NULL THEN 1 ELSE 0 END, users.username ASC, ' +
        'CASE WHEN users.email IS NULL THEN 1 ELSE 0 END, users.email DESC'
      )
    end
  end

  describe '#sort_records with nulls last using column config' do
    it 'can handle multiple sorting columns' do
      # set to order by Users username in ascending order, and
      # by Users email in descending order
      nulls_last_datatable.params[:order]['0'] = { column: '0', dir: 'asc' }
      nulls_last_datatable.params[:order]['1'] = { column: '1', dir: 'desc' }
      expect(nulls_last_datatable.sort_records(records).to_sql).to include(
        'ORDER BY users.username ASC, ' +
        'CASE WHEN users.email IS NULL THEN 1 ELSE 0 END, users.email DESC'
      )
    end
  end

end
