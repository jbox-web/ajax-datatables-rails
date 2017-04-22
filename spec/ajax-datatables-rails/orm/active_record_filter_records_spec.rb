require 'spec_helper'

describe 'AjaxDatatablesRails::ORM::ActiveRecord#filter_records' do
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

  describe 'filter records' do
    let(:records) { User.all }

    it 'requires a records collection as argument' do
      expect { datatable.send(:filter_records) }.to raise_error(ArgumentError)
    end

    it 'performs a simple search first' do
      datatable.params[:search] = { value: 'msmith' }
      expect(datatable).to receive(:build_conditions_for_datatable)
      datatable.send(:filter_records, records)
    end

    it 'performs a composite search second' do
      datatable.params[:search] = { value: '' }
      expect(datatable).to receive(:build_conditions_for_selected_columns)
      datatable.send(:filter_records, records)
    end

    describe '#build_conditions_for_datatable' do
      it 'returns an Arel object' do
        datatable.params[:search] = { value: 'msmith' }
        result = datatable.send(:build_conditions_for_datatable)
        expect(result).to be_a(Arel::Nodes::Grouping)
      end

      context 'no search query' do
        it 'returns empty query' do
          datatable.params[:search] = { value: '' }
          expect(datatable.send(:build_conditions_for_datatable)).to be_blank
        end
      end

      context 'none of columns are connected' do
        before(:each) do
          allow(datatable).to receive(:searchable_columns) { [] }
        end

        it 'returns empty query result' do
          datatable.params[:search] = { value: 'msmith' }
          expect(datatable.send(:build_conditions_for_datatable)).to be_blank
        end
      end

      context 'with search query' do
        before(:each) do
          datatable.params[:search] = { value: "John", regex: "false" }
        end

        it 'returns a filtering query' do
          query = datatable.send(:build_conditions_for_datatable)
          results = records.where(query).map(&:username)
          expect(results).to include('johndoe')
          expect(results).not_to include('msmith')
        end
      end
    end

    describe '#build_conditions_for_selected_columns' do
      context 'columns include search query' do
        before do
          datatable.params[:columns]['0'][:search][:value] = 'doe'
          datatable.params[:columns]['1'][:search][:value] = 'example'
        end

        it 'returns an Arel object' do
          result = datatable.send(:build_conditions_for_selected_columns)
          expect(result).to be_a(Arel::Nodes::And)
        end

        it 'can call #to_sql on returned object' do
          result = datatable.send(:build_conditions_for_selected_columns)
          expect(result).to respond_to(:to_sql)
          expect(result.to_sql).to eq(
            "CAST(\"users\".\"username\" AS TEXT) LIKE '%doe%' AND CAST(\"users\".\"email\" AS TEXT) LIKE '%example%'"
          )
        end
      end

      it 'calls #build_conditions_for_selected_columns' do
        expect(datatable).to receive(:build_conditions_for_selected_columns)
        datatable.send(:build_conditions)
      end

      context 'with search values in columns' do
        before(:each) do
          datatable.params[:columns]['0'][:search][:value] = 'doe'
        end

        it 'returns a filtered set of records' do
          query = datatable.send(:build_conditions_for_selected_columns)
          results = records.where(query).map(&:username)
          expect(results).to include('johndoe')
          expect(results).not_to include('msmith')
        end
      end
    end

    describe '#typecast helper method' do
      let(:view) { double('view', params: sample_params) }
      let(:column) { ComplexDatatable.new(view).datatable.columns.first }

      it 'returns VARCHAR if :db_adapter is :pg' do
        allow_any_instance_of(AjaxDatatablesRails::Configuration).to receive(:db_adapter) { :pg }
        expect(column.send(:typecast)).to eq('VARCHAR')
      end

      it 'returns VARCHAR if :db_adapter is :postgre' do
        allow_any_instance_of(AjaxDatatablesRails::Configuration).to receive(:db_adapter) { :postgre }
        expect(column.send(:typecast)).to eq('VARCHAR')
      end

      it 'returns CHAR if :db_adapter is :mysql2' do
        allow_any_instance_of(AjaxDatatablesRails::Configuration).to receive(:db_adapter) { :mysql2 }
        expect(column.send(:typecast)).to eq('CHAR')
      end

      it 'returns CHAR if :db_adapter is :mysql' do
        allow_any_instance_of(AjaxDatatablesRails::Configuration).to receive(:db_adapter) { :mysql }
        expect(column.send(:typecast)).to eq('CHAR')
      end

      it 'returns TEXT if :db_adapter is :sqlite' do
        allow_any_instance_of(AjaxDatatablesRails::Configuration).to receive(:db_adapter) { :sqlite }
        expect(column.send(:typecast)).to eq('TEXT')
      end

      it 'returns TEXT if :db_adapter is :sqlite3' do
        allow_any_instance_of(AjaxDatatablesRails::Configuration).to receive(:db_adapter) { :sqlite3 }
        expect(column.send(:typecast)).to eq('TEXT')
      end
    end
  end
end
