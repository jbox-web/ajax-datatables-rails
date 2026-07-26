# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AjaxDatatablesRails::ORM::ActiveRecord do

  let(:datatable) { ComplexDatatable.new(sample_params) }
  let(:nulls_last_datatable) { DatatableOrderNullsLast.new(sample_params) }
  let(:records) { User.all }

  before do
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

    it 'does not sort a column which is not orderable' do
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

  describe '#sort_records with a column whose source is not a database column' do
    # 'post' resolves to User.post, which is not a physical column (the column is
    # post_id) — an ORDER BY against users.post would raise StatementInvalid.
    let(:datatable) { DatatableNonexistentColumn.new(sample_params) }

    before do
      datatable.params[:columns]['8'] = {
        'data' => 'post', 'name' => '', 'searchable' => 'false', 'orderable' => 'true',
        'search' => { 'value' => '', 'regex' => 'false' }
      }
      datatable.params[:order]['0'] = { column: '8', dir: 'asc' }
    end

    it 'skips the non-existent column instead of raising' do
      expect { datatable.sort_records(records).load }.to_not raise_error
      expect(datatable.sort_records(records).to_sql).to_not include('users.post')
    end
  end

  describe '#sort_records with json (array-form) params' do
    let(:datatable) { ComplexDatatable.new(sample_params_json) }

    it 'sorts using the array-form order param' do
      datatable.params[:order] = [{ 'column' => '1', 'dir' => 'desc' }]
      expect(datatable.sort_records(records).to_sql).to include('ORDER BY users.email DESC')
    end
  end

  # A JSON body preserves the native JS types, so `column` arrives as an Integer
  # while Column#index, built from the params hash key, is a String. Comparing
  # the two raw values never matched and the ORDER BY was silently dropped: the
  # request answered 200 with unsorted rows and no error anywhere.
  describe '#sort_records with json params carrying native types' do
    let(:datatable) { ComplexDatatable.new(sample_params_json_native) }

    it 'sorts on the requested column' do
      datatable.params[:order] = [{ 'column' => 1, 'dir' => 'desc' }]
      expect(datatable.sort_records(records).to_sql).to include('ORDER BY users.email DESC')
    end

    it 'honours the requested direction' do
      datatable.params[:order] = [{ 'column' => 1, 'dir' => 'asc' }]
      expect(datatable.sort_records(records).to_sql).to include('ORDER BY users.email ASC')
    end

    it 'handles multiple sorting columns' do
      datatable.params[:order] = [
        { 'column' => 0, 'dir' => 'asc' },
        { 'column' => 1, 'dir' => 'desc' },
      ]
      expect(datatable.sort_records(records).to_sql).to include(
        'ORDER BY users.username ASC, users.email DESC'
      )
    end

    # post_id is declared `orderable: false` in ComplexDatatable#view_columns.
    it 'still skips a column which is not orderable' do
      datatable.params[:order] = [{ 'column' => 5, 'dir' => 'asc' }]
      expect(datatable.sort_records(records).to_sql).to_not include('ORDER BY')
    end

    it 'actually reorders the records' do
      datatable.params[:order] = [{ 'column' => 1, 'dir' => 'desc' }]
      expect(datatable.sort_records(records).map(&:email)).to eq(
        ['mary.smith@example.com', 'johndoe@example.com']
      )
    end
  end

  describe '#sort_records with nulls last using global config' do
    before { datatable.nulls_last = true }
    after  { datatable.nulls_last = false }

    it 'can handle multiple sorting columns' do
      # set to order by Users username in ascending order, and
      # by Users email in descending order
      datatable.params[:order]['0'] = { column: '0', dir: 'asc' }
      datatable.params[:order]['1'] = { column: '1', dir: 'desc' }
      expect(datatable.sort_records(records).to_sql).to include(
        "ORDER BY #{nulls_last_term(datatable, 'users.username', 'ASC')}, #{nulls_last_term(datatable, 'users.email', 'DESC')}"
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
        "ORDER BY users.username ASC, #{nulls_last_term(datatable, 'users.email', 'DESC')}"
      )
    end
  end

  describe '#sort_records with nulls last executed against the database' do
    before do
      create(:user, username: 'aaa', email: nil)
      create(:user, username: 'zzz', email: nil)
    end

    it 'orders NULLs last without raising a SQL syntax error' do
      # order by email DESC with nulls_last enabled on the email column
      nulls_last_datatable.params[:order]['0'] = { column: '1', dir: 'desc' }

      emails = nil
      expect { emails = nulls_last_datatable.sort_records(records).map(&:email) }.to_not raise_error
      # non-null values come first (DESC), the two NULLs are pushed to the end
      expect(emails.first).to eq('mary.smith@example.com')
      expect(emails.last(2)).to eq([nil, nil])
    end
  end

end
