# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AjaxDatatablesRails::ORM::ActiveRecord do

  let(:datatable) { ComplexDatatable.new(sample_params) }
  let(:records) { User.all }

  describe '#filter_records' do
    it 'requires a records collection as argument' do
      expect { datatable.filter_records }.to raise_error(ArgumentError)
    end

    it 'performs a simple search first' do
      datatable.params[:search] = { value: 'msmith' }
      expect(datatable).to receive(:build_conditions_for_datatable)
      datatable.filter_records(records)
    end

    it 'performs a composite search second' do
      datatable.params[:search] = { value: '' }
      expect(datatable).to receive(:build_conditions_for_selected_columns)
      datatable.filter_records(records)
    end
  end

  describe '#build_conditions' do
    before do
      create(:user, username: 'johndoe', email: 'johndoe@example.com')
      create(:user, username: 'msmith',  email: 'mary.smith@example.com')
      create(:user, username: 'hsmith',  email: 'henry.smith@example.net')
    end

    context 'with column and global search' do
      before do
        datatable.params[:search] = { value: 'example.com', regex: 'false' }
        datatable.params[:columns]['0'][:search][:value] = 'smith'
      end

      it 'return a filtered set of records' do
        query = datatable.build_conditions
        results = records.where(query).map(&:username)
        expect(results).to include('msmith')
        expect(results).not_to include('johndoe')
        expect(results).not_to include('hsmith')
      end
    end
  end

  describe '#build_conditions_for_datatable' do
    before do
      create(:user, username: 'johndoe', email: 'johndoe@example.com')
      create(:user, username: 'msmith', email: 'mary.smith@example.com')
    end

    it 'returns an Arel object' do
      datatable.params[:search] = { value: 'msmith' }
      result = datatable.build_conditions_for_datatable
      expect(result).to be_a(Arel::Nodes::Grouping)
    end

    context 'no search query' do
      it 'returns empty query' do
        datatable.params[:search] = { value: '' }
        expect(datatable.build_conditions_for_datatable).to be_blank
      end
    end

    context 'when none of columns are connected' do
      before do
        allow(datatable).to receive(:searchable_columns) { [] }
      end

      context 'when search value is a string' do
        before do
          datatable.params[:search] = { value: 'msmith' }
        end

        it 'returns empty query result' do
          expect(datatable.build_conditions_for_datatable).to be_blank
        end

        it 'returns filtered results' do
          query = datatable.build_conditions_for_datatable
          results = records.where(query).map(&:username)
          expect(results).to eq ['johndoe', 'msmith']
        end
      end

      context 'when search value is space-separated string' do
        before do
          datatable.params[:search] = { value: 'foo bar' }
        end

        it 'returns empty query result' do
          expect(datatable.build_conditions_for_datatable).to be_blank
        end

        it 'returns filtered results' do
          query = datatable.build_conditions_for_datatable
          results = records.where(query).map(&:username)
          expect(results).to eq ['johndoe', 'msmith']
        end
      end
    end

    context 'with search query' do
      context 'when search value is a string' do
        before do
          datatable.params[:search] = { value: 'john', regex: 'false' }
        end

        it 'returns a filtering query' do
          query = datatable.build_conditions_for_datatable
          results = records.where(query).map(&:username)
          expect(results).to include('johndoe')
          expect(results).not_to include('msmith')
        end
      end

      context 'when search value is space-separated string' do
        before do
          datatable.params[:search] = { value: 'john doe', regex: 'false' }
        end

        it 'returns a filtering query' do
          query = datatable.build_conditions_for_datatable
          results = records.where(query).map(&:username)
          expect(results).to eq ['johndoe']
          expect(results).not_to include('msmith')
        end
      end

      # TODO: improve (or delete?) this test
      context 'when column.search_query returns nil' do
        let(:datatable) { DatatableCondUnknown.new(sample_params) }

        before do
          datatable.params[:search] = { value: 'john doe', regex: 'false' }
        end

        it 'does not raise error' do
          allow_any_instance_of(AjaxDatatablesRails::Datatable::Column).to receive(:valid_search_condition?).and_return(true)

          expect {
            datatable.data.size
          }.to_not raise_error
        end
      end
    end
  end

  describe '#build_conditions_for_selected_columns' do
    before do
      create(:user, username: 'johndoe', email: 'johndoe@example.com')
      create(:user, username: 'msmith', email: 'mary.smith@example.com')
    end

    context 'columns include search query' do
      before do
        datatable.params[:columns]['0'][:search][:value] = 'doe'
        datatable.params[:columns]['1'][:search][:value] = 'example'
      end

      it 'returns an Arel object' do
        result = datatable.build_conditions_for_selected_columns
        expect(result).to be_a(Arel::Nodes::And)
      end

      if ENV['DB_ADAPTER'] == 'postgresql'
        context 'when db_adapter is postgresql' do
          it 'can call #to_sql on returned object' do
            result = datatable.build_conditions_for_selected_columns
            expect(result).to respond_to(:to_sql)
            expect(result.to_sql).to eq(
              "CAST(\"users\".\"username\" AS VARCHAR) ILIKE '%doe%' AND CAST(\"users\".\"email\" AS VARCHAR) ILIKE '%example%'"
            )
          end
        end
      end

      if ENV['DB_ADAPTER'] == 'oracle_enhanced'
        context 'when db_adapter is oracle' do
          it 'can call #to_sql on returned object' do
            result = datatable.build_conditions_for_selected_columns
            expect(result).to respond_to(:to_sql)
            expect(result.to_sql).to eq(
              "CAST(\"USERS\".\"USERNAME\" AS VARCHAR2(4000)) LIKE '%doe%' AND CAST(\"USERS\".\"EMAIL\" AS VARCHAR2(4000)) LIKE '%example%'"
            )
          end
        end
      end

      if ENV['DB_ADAPTER'] == 'mysql2'
        context 'when db_adapter is mysql2' do
          it 'can call #to_sql on returned object' do
            result = datatable.build_conditions_for_selected_columns
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
      datatable.build_conditions
    end

    context 'with search values in columns' do
      before do
        datatable.params[:columns]['0'][:search][:value] = 'doe'
      end

      it 'returns a filtered set of records' do
        query = datatable.build_conditions_for_selected_columns
        results = records.where(query).map(&:username)
        expect(results).to include('johndoe')
        expect(results).not_to include('msmith')
      end
    end
  end

  describe 'filter conditions' do
    context 'date condition' do
      describe 'it can filter records with condition :date_range' do
        let(:datatable) { DatatableCondDate.new(sample_params) }

        before do
          create(:user, username: 'johndoe', email: 'johndoe@example.com', last_name: 'Doe', created_at: '01/01/2000')
          create(:user, username: 'msmith', email: 'mary.smith@example.com', last_name: 'Smith', created_at: '01/02/2000')
        end

        context 'when range is empty' do
          it 'does not filter records' do
            datatable.params[:columns]['5'][:search][:value] = '-'
            expect(datatable.data.size).to eq 2
            item = datatable.data.first
            expect(item[:last_name]).to eq 'Doe'
          end
        end

        context 'when start date is filled' do
          it 'filters records created after this date' do
            datatable.params[:columns]['5'][:search][:value] = '31/12/1999-'
            expect(datatable.data.size).to eq 2
          end
        end

        context 'when end date is filled' do
          it 'filters records created before this date' do
            datatable.params[:columns]['5'][:search][:value] = '-31/12/1999'
            expect(datatable.data.size).to eq 0
          end
        end

        context 'when both date are filled' do
          it 'filters records created between the range' do
            datatable.params[:columns]['5'][:search][:value] = '01/12/1999-15/01/2000'
            expect(datatable.data.size).to eq 1
          end
        end

        context 'when another filter is active' do
          context 'when range is empty' do
            it 'filters records' do
              datatable.params[:columns]['0'][:search][:value] = 'doe'
              datatable.params[:columns]['5'][:search][:value] = '-'
              expect(datatable.data.size).to eq 1
              item = datatable.data.first
              expect(item[:last_name]).to eq 'Doe'
            end
          end

          context 'when start date is filled' do
            it 'filters records' do
              datatable.params[:columns]['0'][:search][:value] = 'doe'
              datatable.params[:columns]['5'][:search][:value] = '01/12/1999-'
              expect(datatable.data.size).to eq 1
              item = datatable.data.first
              expect(item[:last_name]).to eq 'Doe'
            end
          end

          context 'when end date is filled' do
            it 'filters records' do
              datatable.params[:columns]['0'][:search][:value] = 'doe'
              datatable.params[:columns]['5'][:search][:value] = '-15/01/2000'
              expect(datatable.data.size).to eq 1
              item = datatable.data.first
              expect(item[:last_name]).to eq 'Doe'
            end
          end

          context 'when both date are filled' do
            it 'filters records' do
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

    context 'numeric condition' do
      before do
        create(:user, first_name: 'john', post_id: 1)
        create(:user, first_name: 'mary', post_id: 2)
      end

      describe 'it can filter records with condition :eq' do
        let(:datatable) { DatatableCondEq.new(sample_params) }

        it 'filters records matching' do
          datatable.params[:columns]['4'][:search][:value] = 1
          expect(datatable.data.size).to eq 1
          item = datatable.data.first
          expect(item[:first_name]).to eq 'john'
        end
      end

      describe 'it can filter records with condition :not_eq' do
        let(:datatable) { DatatableCondNotEq.new(sample_params) }

        it 'filters records matching' do
          datatable.params[:columns]['4'][:search][:value] = 1
          expect(datatable.data.size).to eq 1
          item = datatable.data.first
          expect(item[:first_name]).to eq 'mary'
        end
      end

      describe 'it can filter records with condition :lt' do
        let(:datatable) { DatatableCondLt.new(sample_params) }

        it 'filters records matching' do
          datatable.params[:columns]['4'][:search][:value] = 2
          expect(datatable.data.size).to eq 1
          item = datatable.data.first
          expect(item[:first_name]).to eq 'john'
        end
      end

      describe 'it can filter records with condition :gt' do
        let(:datatable) { DatatableCondGt.new(sample_params) }

        it 'filters records matching' do
          datatable.params[:columns]['4'][:search][:value] = 1
          expect(datatable.data.size).to eq 1
          item = datatable.data.first
          expect(item[:first_name]).to eq 'mary'
        end
      end

      describe 'it can filter records with condition :lteq' do
        let(:datatable) { DatatableCondLteq.new(sample_params) }

        it 'filters records matching' do
          datatable.params[:columns]['4'][:search][:value] = 2
          expect(datatable.data.size).to eq 2
        end
      end

      describe 'it can filter records with condition :gteq' do
        let(:datatable) { DatatableCondGteq.new(sample_params) }

        it 'filters records matching' do
          datatable.params[:columns]['4'][:search][:value] = 1
          expect(datatable.data.size).to eq 2
        end
      end

      describe 'it can filter records with condition :in' do
        let(:datatable) { DatatableCondIn.new(sample_params) }

        it 'filters records matching' do
          datatable.params[:columns]['4'][:search][:value] = [1]
          expect(datatable.data.size).to eq 1
          item = datatable.data.first
          expect(item[:first_name]).to eq 'john'
        end
      end

      describe 'it can filter records with condition :in with regex' do
        let(:datatable) { DatatableCondInWithRegex.new(sample_params) }

        it 'filters records matching' do
          datatable.params[:columns]['4'][:search][:value] = '1|2'
          datatable.params[:order]['0'] = { column: '4', dir: 'asc' }
          expect(datatable.data.size).to eq 2
          item = datatable.data.first
          expect(item[:first_name]).to eq 'john'
        end
      end

      describe 'Integer overflows' do
        let(:datatable) { DatatableCondEq.new(sample_params) }
        let(:largest_postgresql_integer_value) { 2_147_483_647 }
        let(:smallest_postgresql_integer_value) { -2_147_483_648 }

        before do
          create(:user, first_name: 'john', post_id: 1)
          create(:user, first_name: 'mary', post_id: 2)
          create(:user, first_name: 'phil', post_id: largest_postgresql_integer_value)
        end

        it 'Returns an empty result if input value is too large' do
          datatable.params[:columns]['4'][:search][:value] = largest_postgresql_integer_value + 1
          expect(datatable.data.size).to eq 0
        end

        it 'Returns an empty result if input value is too small' do
          datatable.params[:columns]['4'][:search][:value] = smallest_postgresql_integer_value - 1
          expect(datatable.data.size).to eq 0
        end

        it 'returns the matching user' do
          datatable.params[:columns]['4'][:search][:value] = largest_postgresql_integer_value
          expect(datatable.data.size).to eq 1
        end
      end
    end

    context 'proc condition' do
      describe 'it can filter records with lambda/proc condition' do
        let(:datatable) { DatatableCondProc.new(sample_params) }

        before do
          create(:user, username: 'johndoe', email: 'johndoe@example.com')
          create(:user, username: 'johndie', email: 'johndie@example.com')
          create(:user, username: 'msmith',  email: 'mary.smith@example.com')
        end

        it 'filters records matching' do
          datatable.params[:columns]['0'][:search][:value] = 'john'
          expect(datatable.data.size).to eq 2
          item = datatable.data.first
          expect(item[:username]).to eq 'johndie'
        end
      end
    end

    context 'string condition' do
      describe 'it can filter records with condition :start_with' do
        let(:datatable) { DatatableCondStartWith.new(sample_params) }

        before do
          create(:user, first_name: 'John')
          create(:user, first_name: 'Mary')
        end

        it 'filters records matching' do
          datatable.params[:columns]['2'][:search][:value] = 'Jo'
          expect(datatable.data.size).to eq 1
          item = datatable.data.first
          expect(item[:first_name]).to eq 'John'
        end
      end

      describe 'it can filter records with condition :end_with' do
        let(:datatable) { DatatableCondEndWith.new(sample_params) }

        before do
          create(:user, last_name: 'JOHN')
          create(:user, last_name: 'MARY')
        end

        if ENV['DB_ADAPTER'] == 'oracle_enhanced'
          context 'when db_adapter is oracleenhanced' do
            it 'filters records matching' do
              datatable.params[:columns]['3'][:search][:value] = 'RY'
              expect(datatable.data.size).to eq 1
              item = datatable.data.first
              expect(item[:last_name]).to eq 'MARY'
            end
          end
        else
          it 'filters records matching' do
            datatable.params[:columns]['3'][:search][:value] = 'ry'
            expect(datatable.data.size).to eq 1
            item = datatable.data.first
            expect(item[:last_name]).to eq 'MARY'
          end
        end
      end

      describe 'it can filter records with condition :like' do
        let(:datatable) { DatatableCondLike.new(sample_params) }

        before do
          create(:user, email: 'john@foo.com')
          create(:user, email: 'mary@bar.com')
        end

        it 'filters records matching' do
          datatable.params[:columns]['1'][:search][:value] = 'foo'
          expect(datatable.data.size).to eq 1
          item = datatable.data.first
          expect(item[:email]).to eq 'john@foo.com'
        end
      end

      describe 'it can filter records with condition :string_eq' do
        let(:datatable) { DatatableCondStringEq.new(sample_params) }

        before do
          create(:user, email: 'john@foo.com')
          create(:user, email: 'mary@bar.com')
        end

        it 'filters records matching' do
          datatable.params[:columns]['1'][:search][:value] = 'john@foo.com'
          expect(datatable.data.size).to eq 1
          item = datatable.data.first
          expect(item[:email]).to eq 'john@foo.com'
        end
      end

      describe 'it can filter records with condition :string_in' do
        let(:datatable) { DatatableCondStringIn.new(sample_params) }

        before do
          create(:user, email: 'john@foo.com')
          create(:user, email: 'mary@bar.com')
          create(:user, email: 'henry@baz.com')
        end

        it 'filters records matching' do
          datatable.params[:columns]['1'][:search][:value] = 'john@foo.com'
          expect(datatable.data.size).to eq 1
          item = datatable.data.first
          expect(item[:email]).to eq 'john@foo.com'
        end

        it 'filters records matching with multiple' do
          datatable.params[:columns]['1'][:search][:value] = 'john@foo.com|henry@baz.com'
          expect(datatable.data.size).to eq 2
          items = datatable.data.sort_by { |h| h[:email] }
          item_first = items.first
          item_last = items.last
          expect(item_first[:email]).to eq 'henry@baz.com'
          expect(item_last[:email]).to eq 'john@foo.com'
        end

        it 'filters records matching with multiple contains not found' do
          datatable.params[:columns]['1'][:search][:value] = 'john@foo.com|henry_not@baz.com'
          expect(datatable.data.size).to eq 1
          item = datatable.data.first
          expect(item[:email]).to eq 'john@foo.com'
        end
      end

      describe 'it can filter records with condition :null_value' do
        let(:datatable) { DatatableCondNullValue.new(sample_params) }

        before do
          create(:user, first_name: 'john', email: 'foo@bar.com')
          create(:user, first_name: 'mary', email: nil)
        end

        context 'when condition is NULL' do
          it 'filters records matching' do
            datatable.params[:columns]['1'][:search][:value] = 'NULL'
            expect(datatable.data.size).to eq 1
            item = datatable.data.first
            expect(item[:first_name]).to eq 'mary'
          end
        end

        context 'when condition is !NULL' do
          it 'filters records matching' do
            datatable.params[:columns]['1'][:search][:value] = '!NULL'
            expect(datatable.data.size).to eq 1
            item = datatable.data.first
            expect(item[:first_name]).to eq 'john'
          end
        end
      end
    end

    context 'unknown condition' do
      let(:datatable) { DatatableCondUnknown.new(sample_params) }

      before do
        datatable.params[:search] = { value: 'john doe', regex: 'false' }
      end

      it 'raises error' do
        expect {
          datatable.data.size
        }.to raise_error(AjaxDatatablesRails::Error::InvalidSearchCondition).with_message('foo')
      end
    end
  end

  describe 'formatter option' do
    let(:datatable) { DatatableWithFormater.new(sample_params) }

    before do
      create(:user, username: 'johndoe', email: 'johndoe@example.com', last_name: 'DOE')
      create(:user, username: 'msmith', email: 'mary.smith@example.com', last_name: 'SMITH')
      datatable.params[:columns]['3'][:search][:value] = 'doe'
    end

    it 'can transform search value before asking the database' do
      expect(datatable.data.size).to eq 1
      item = datatable.data.first
      expect(item[:last_name]).to eq 'DOE'
    end
  end
end
