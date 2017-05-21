require 'spec_helper'

describe AjaxDatatablesRails::ORM::ActiveRecord do

  let(:view) { double('view', params: sample_params) }
  let(:datatable) { ComplexDatatable.new(view) }
  let(:records) { User.all }

  describe '#filter_records' do
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
  end

  describe '#build_conditions_for_datatable' do
    before(:each) do
      create(:user, username: 'johndoe', email: 'johndoe@example.com')
      create(:user, username: 'msmith', email: 'mary.smith@example.com')
    end

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
        datatable.params[:search] = { value: "john", regex: "false" }
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
    before(:each) do
      create(:user, username: 'johndoe', email: 'johndoe@example.com')
      create(:user, username: 'msmith', email: 'mary.smith@example.com')
    end

    context 'columns include search query' do
      before do
        datatable.params[:columns]['0'][:search][:value] = 'doe'
        datatable.params[:columns]['1'][:search][:value] = 'example'
      end

      it 'returns an Arel object' do
        result = datatable.send(:build_conditions_for_selected_columns)
        expect(result).to be_a(Arel::Nodes::And)
      end

      if AjaxDatatablesRails.config.db_adapter == :postgresql
        context 'when db_adapter is postgresql' do
          it 'can call #to_sql on returned object' do
            result = datatable.send(:build_conditions_for_selected_columns)
            expect(result).to respond_to(:to_sql)
            expect(result.to_sql).to eq(
              "CAST(\"users\".\"username\" AS VARCHAR) ILIKE '%doe%' AND CAST(\"users\".\"email\" AS VARCHAR) ILIKE '%example%'"
            )
          end
        end
      end

      if AjaxDatatablesRails.config.db_adapter.in? %i[oracle oracleenhanced]
        context 'when db_adapter is oracle' do
          it 'can call #to_sql on returned object' do
            result = datatable.send(:build_conditions_for_selected_columns)
            expect(result).to respond_to(:to_sql)
            expect(result.to_sql).to eq(
              "CAST(\"USERS\".\"USERNAME\" AS VARCHAR2(4000)) LIKE '%doe%' AND CAST(\"USERS\".\"EMAIL\" AS VARCHAR2(4000)) LIKE '%example%'"
            )
          end
        end
      end

      if AjaxDatatablesRails.config.db_adapter.in? %i[mysql2 sqlite3]
        context 'when db_adapter is mysql2' do
          it 'can call #to_sql on returned object' do
            result = datatable.send(:build_conditions_for_selected_columns)
            expect(result).to respond_to(:to_sql)
            expect(result.to_sql).to eq(
              "CAST(`users`.`username` AS CHAR) LIKE '%doe%' AND CAST(`users`.`email` AS CHAR) LIKE '%example%'"
            )
          end
        end
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

    it 'returns VARCHAR if :db_adapter is :postgresql' do
      allow_any_instance_of(AjaxDatatablesRails::Configuration).to receive(:db_adapter) { :postgresql }
      expect(column.send(:typecast)).to eq('VARCHAR')
    end

    it 'returns VARCHAR if :db_adapter is :oracle' do
      allow_any_instance_of(AjaxDatatablesRails::Configuration).to receive(:db_adapter) { :oracle }
      expect(column.send(:typecast)).to eq('VARCHAR2(4000)')
    end

    it 'returns VARCHAR if :db_adapter is :oracleenhanced' do
      allow_any_instance_of(AjaxDatatablesRails::Configuration).to receive(:db_adapter) { :oracleenhanced }
      expect(column.send(:typecast)).to eq('VARCHAR2(4000)')
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

  describe 'filter conditions' do
    let(:datatable) { ReallyComplexDatatable.new(view) }

    unless AjaxDatatablesRails.old_rails?
      describe 'it can filter records with condition :date_range' do
        before(:each) do
          create(:user, username: 'johndoe', email: 'johndoe@example.com', last_name: 'Doe', created_at: '01/01/2000')
          create(:user, username: 'msmith', email: 'mary.smith@example.com', last_name: 'Smith', created_at: '01/02/2000')
        end

        context 'when range is empty' do
          it 'should not filter records' do
            datatable.params[:columns]['5'][:search][:value] = '-'
            expect(datatable.data.size).to eq 2
            item = datatable.data.first
            expect(item[:last_name]).to eq 'Doe'
          end
        end

        context 'when start date is filled' do
          it 'should filter records created after this date' do
            datatable.params[:columns]['5'][:search][:value] = '31/12/1999-'
            expect(datatable.data.size).to eq 2
          end
        end

        context 'when end date is filled' do
          it 'should filter records created before this date' do
            datatable.params[:columns]['5'][:search][:value] = '-31/12/1999'
            expect(datatable.data.size).to eq 0
          end
        end

        context 'when both date are filled' do
          it 'should filter records created between the range' do
            datatable.params[:columns]['5'][:search][:value] = '01/12/1999-15/01/2000'
            expect(datatable.data.size).to eq 1
          end
        end

        context 'when another filter is active' do
          context 'when range is empty' do
            it 'should filter records' do
              datatable.params[:columns]['0'][:search][:value] = 'doe'
              datatable.params[:columns]['5'][:search][:value] = '-'
              expect(datatable.data.size).to eq 1
              item = datatable.data.first
              expect(item[:last_name]).to eq 'Doe'
            end
          end

          context 'when start date is filled' do
            it 'should filter records' do
              datatable.params[:columns]['0'][:search][:value] = 'doe'
              datatable.params[:columns]['5'][:search][:value] = '01/12/1999-'
              expect(datatable.data.size).to eq 1
              item = datatable.data.first
              expect(item[:last_name]).to eq 'Doe'
            end
          end

          context 'when end date is filled' do
            it 'should filter records' do
              datatable.params[:columns]['0'][:search][:value] = 'doe'
              datatable.params[:columns]['5'][:search][:value] = '-15/01/2000'
              expect(datatable.data.size).to eq 1
              item = datatable.data.first
              expect(item[:last_name]).to eq 'Doe'
            end
          end

          context 'when both date are filled' do
            it 'should filter records' do
              datatable.params[:columns]['0'][:search][:value] = 'doe'
              datatable.params[:columns]['5'][:search][:value] = '01/12/1999-15/01/2000'
              expect(datatable.data.size).to eq 1
              item = datatable.data.first
              expect(item[:last_name]).to eq 'Doe'
            end
          end
        end
      end
    end

    describe 'it can filter records with condition :start_with' do
      before(:each) do
        create(:user, first_name: 'John')
        create(:user, first_name: 'Mary')
      end

      it 'should filter records matching' do
        datatable.params[:columns]['2'][:search][:value] = 'Jo'
        expect(datatable.data.size).to eq 1
        item = datatable.data.first
        expect(item[:first_name]).to eq 'John'
      end
    end

    describe 'it can filter records with condition :end_with' do
      before(:each) do
        create(:user, last_name: 'JOHN')
        create(:user, last_name: 'MARY')
      end

      it 'should filter records matching' do
        datatable.params[:columns]['3'][:search][:value] = 'ry'
        expect(datatable.data.size).to eq 1
        item = datatable.data.first
        expect(item[:last_name]).to eq 'MARY'
      end
    end

    describe 'it can filter records with condition :null_value' do
      before(:each) do
        create(:user, first_name: 'john', email: 'foo@bar.com')
        create(:user, first_name: 'mary', email: nil)
      end

      context 'when condition is NULL' do
        it 'should filter records matching' do
          datatable.params[:columns]['1'][:search][:value] = 'NULL'
          expect(datatable.data.size).to eq 1
          item = datatable.data.first
          expect(item[:first_name]).to eq 'mary'
        end
      end

      context 'when condition is !NULL' do
        it 'should filter records matching' do
          datatable.params[:columns]['1'][:search][:value] = '!NULL'
          expect(datatable.data.size).to eq 1
          item = datatable.data.first
          expect(item[:first_name]).to eq 'john'
        end
      end
    end

    describe 'it can filter records with condition :eq' do
      let(:datatable) { ReallyComplexDatatableEq.new(view) }

      before(:each) do
        create(:user, first_name: 'john', post_id: 1)
        create(:user, first_name: 'mary', post_id: 2)
      end

      it 'should filter records matching' do
        datatable.params[:columns]['4'][:search][:value] = 1
        expect(datatable.data.size).to eq 1
        item = datatable.data.first
        expect(item[:first_name]).to eq 'john'
      end
    end

    describe 'it can filter records with condition :not_eq' do
      let(:datatable) { ReallyComplexDatatableNotEq.new(view) }

      before(:each) do
        create(:user, first_name: 'john', post_id: 1)
        create(:user, first_name: 'mary', post_id: 2)
      end

      it 'should filter records matching' do
        datatable.params[:columns]['4'][:search][:value] = 1
        expect(datatable.data.size).to eq 1
        item = datatable.data.first
        expect(item[:first_name]).to eq 'mary'
      end
    end

    describe 'it can filter records with condition :lt' do
      let(:datatable) { ReallyComplexDatatableLt.new(view) }

      before(:each) do
        create(:user, first_name: 'john', post_id: 1)
        create(:user, first_name: 'mary', post_id: 2)
      end

      it 'should filter records matching' do
        datatable.params[:columns]['4'][:search][:value] = 2
        expect(datatable.data.size).to eq 1
        item = datatable.data.first
        expect(item[:first_name]).to eq 'john'
      end
    end

    describe 'it can filter records with condition :gt' do
      let(:datatable) { ReallyComplexDatatableGt.new(view) }

      before(:each) do
        create(:user, first_name: 'john', post_id: 1)
        create(:user, first_name: 'mary', post_id: 2)
      end

      it 'should filter records matching' do
        datatable.params[:columns]['4'][:search][:value] = 1
        expect(datatable.data.size).to eq 1
        item = datatable.data.first
        expect(item[:first_name]).to eq 'mary'
      end
    end

    describe 'it can filter records with condition :lteq' do
      let(:datatable) { ReallyComplexDatatableLteq.new(view) }

      before(:each) do
        create(:user, first_name: 'john', post_id: 1)
        create(:user, first_name: 'mary', post_id: 2)
      end

      it 'should filter records matching' do
        datatable.params[:columns]['4'][:search][:value] = 2
        expect(datatable.data.size).to eq 2
      end
    end

    describe 'it can filter records with condition :gteq' do
      let(:datatable) { ReallyComplexDatatableGteq.new(view) }

      before(:each) do
        create(:user, first_name: 'john', post_id: 1)
        create(:user, first_name: 'mary', post_id: 2)
      end

      it 'should filter records matching' do
        datatable.params[:columns]['4'][:search][:value] = 1
        expect(datatable.data.size).to eq 2
      end
    end

    describe 'it can filter records with condition :in' do
      let(:datatable) { ReallyComplexDatatableIn.new(view) }

      before(:each) do
        create(:user, first_name: 'john', post_id: 1)
        create(:user, first_name: 'mary', post_id: 2)
      end

      it 'should filter records matching' do
        datatable.params[:columns]['4'][:search][:value] = [1]
        expect(datatable.data.size).to eq 1
        item = datatable.data.first
        expect(item[:first_name]).to eq 'john'
      end
    end
  end
end
