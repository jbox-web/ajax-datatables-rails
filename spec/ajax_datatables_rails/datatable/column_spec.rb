# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AjaxDatatablesRails::Datatable::Column do

  let(:datatable) { ComplexDatatable.new(sample_params) }

  describe 'username column' do

    let(:column) { datatable.datatable.columns.first }

    before { datatable.params[:columns]['0'][:search][:value] = 'searchvalue' }

    it 'is orderable' do
      expect(column.orderable?).to be(true)
    end

    it 'sorts nulls last' do
      expect(column.nulls_last?).to be(false)
    end

    it 'is searchable' do
      expect(column.searchable?).to be(true)
    end

    it 'is searched' do
      expect(column.searched?).to be(true)
    end

    it 'has connected to id column' do
      expect(column.data).to eq('username')
    end

    describe '#data' do
      it 'returns the data from params' do
        expect(column.data).to eq 'username'
      end
    end

    describe '#source' do
      it 'returns the data source from view_column' do
        expect(column.source).to eq 'User.username'
      end
    end

    describe '#table' do
      context 'with ActiveRecord ORM' do
        it 'returns the corresponding AR table' do
          expect(column.table).to eq User.arel_table
        end
      end

      context 'with other ORM' do
        it 'returns the corresponding model' do
          allow(User).to receive(:respond_to?).with(:arel_table).and_return(false)
          expect(column.table).to eq User
        end
      end
    end

    describe '#model' do
      it 'returns the corresponding AR model' do
        expect(column.model).to eq User
      end
    end

    describe '#field' do
      it 'returns the corresponding field in DB' do
        expect(column.field).to eq :username
      end
    end

    describe '#custom_field?' do
      it 'returns false if field is bound to an AR field' do
        expect(column.custom_field?).to be false
      end
    end

    describe '#search' do
      it 'child class' do
        expect(column.search).to be_a(AjaxDatatablesRails::Datatable::SimpleSearch)
      end

      it 'has search value' do
        expect(column.search.value).to eq('searchvalue')
      end

      it 'does not regex' do
        expect(column.search.regexp?).to be false
      end
    end

    describe '#cond' do
      it 'is :like by default' do
        expect(column.cond).to eq(:like)
      end
    end

    describe '#search_query' do
      it 'bulds search query' do
        expect(column.search_query.to_sql).to include('%searchvalue%')
      end
    end

    describe '#sort_query' do
      it 'builds sort query' do
        expect(column.sort_query).to eq('users.username')
      end
    end

    describe '#use_regex?' do
      it 'is true by default' do
        expect(column.use_regex?).to be true
      end
    end

    describe '#delimiter' do
      it 'is - by default' do
        expect(column.delimiter).to eq('-')
      end
    end
  end

  describe 'unsearchable column' do
    let(:column) { datatable.datatable.columns.find { |c| c.data == 'email_hash' } }

    it 'is not searchable' do
      expect(column.searchable?).to be(false)
    end
  end

  describe '#formatter' do
    let(:datatable) { DatatableWithFormater.new(sample_params) }
    let(:column) { datatable.datatable.columns.find { |c| c.data == 'last_name' } }

    it 'is a proc' do
      expect(column.formatter).to be_a(Proc)
    end
  end

  describe '#filter' do
    let(:datatable) { DatatableCondProc.new(sample_params) }
    let(:column) { datatable.datatable.columns.find { |c| c.data == 'username' } }

    it 'is a proc' do
      config = column.instance_variable_get(:@view_column)
      filter = config[:cond]
      expect(filter).to be_a(Proc)
      allow(filter).to receive(:call).with(column, column.formatted_value)
      column.filter
      expect(filter).to have_received(:call).with(column, column.formatted_value)
    end
  end

  describe '#type_cast' do
    let(:column) { datatable.datatable.columns.first }

    it 'returns VARCHAR if :db_adapter is :pg' do
      allow(datatable).to receive(:db_adapter).and_return(:pg)
      expect(column.send(:type_cast)).to eq('VARCHAR')
    end

    it 'returns VARCHAR if :db_adapter is :postgre' do
      allow(datatable).to receive(:db_adapter).and_return(:postgre)
      expect(column.send(:type_cast)).to eq('VARCHAR')
    end

    it 'returns VARCHAR if :db_adapter is :postgresql' do
      allow(datatable).to receive(:db_adapter).and_return(:postgresql)
      expect(column.send(:type_cast)).to eq('VARCHAR')
    end

    it 'returns VARCHAR if :db_adapter is :postgis' do
      allow(datatable).to receive(:db_adapter).and_return(:postgis)
      expect(column.send(:type_cast)).to eq('VARCHAR')
    end

    it 'returns VARCHAR2(4000) if :db_adapter is :oracle' do
      allow(datatable).to receive(:db_adapter).and_return(:oracle)
      expect(column.send(:type_cast)).to eq('VARCHAR2(4000)')
    end

    it 'returns VARCHAR2(4000) if :db_adapter is :oracleenhanced' do
      allow(datatable).to receive(:db_adapter).and_return(:oracleenhanced)
      expect(column.send(:type_cast)).to eq('VARCHAR2(4000)')
    end

    it 'returns CHAR if :db_adapter is :mysql2' do
      allow(datatable).to receive(:db_adapter).and_return(:mysql2)
      expect(column.send(:type_cast)).to eq('CHAR')
    end

    it 'returns CHAR if :db_adapter is :trilogy' do
      allow(datatable).to receive(:db_adapter).and_return(:trilogy)
      expect(column.send(:type_cast)).to eq('CHAR')
    end

    it 'returns CHAR if :db_adapter is :mysql' do
      allow(datatable).to receive(:db_adapter).and_return(:mysql)
      expect(column.send(:type_cast)).to eq('CHAR')
    end

    it 'returns TEXT if :db_adapter is :sqlite' do
      allow(datatable).to receive(:db_adapter).and_return(:sqlite)
      expect(column.send(:type_cast)).to eq('TEXT')
    end

    it 'returns TEXT if :db_adapter is :sqlite3' do
      allow(datatable).to receive(:db_adapter).and_return(:sqlite3)
      expect(column.send(:type_cast)).to eq('TEXT')
    end

    it 'returns VARCHAR(4000) if :db_adapter is :sqlserver' do
      allow(datatable).to receive(:db_adapter).and_return(:sqlserver)
      expect(column.send(:type_cast)).to eq('VARCHAR(4000)')
    end
  end

  describe 'when empty column' do
    before { datatable.params[:columns]['0'][:data] = '' }

    let(:message) { 'Unknown column. Check that `data` field is filled on JS side with the column name' }

    it 'raises error' do
      expect { datatable.to_json }.to raise_error(AjaxDatatablesRails::Error::InvalidSearchColumn).with_message(message)
    end
  end

  describe 'when unknown column' do
    before { datatable.params[:columns]['0'][:data] = 'foo' }

    let(:message) { "Check that column 'foo' exists in view_columns" }

    it 'raises error' do
      expect { datatable.to_json }.to raise_error(AjaxDatatablesRails::Error::InvalidSearchColumn).with_message(message)
    end
  end
end
