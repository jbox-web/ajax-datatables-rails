require 'spec_helper'

describe 'AjaxDatatablesRails::ORM::ActiveRecord#filter_records' do
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

  describe 'filter records' do
    let(:records) { User.all }

    it 'requires a records collection as argument' do
      expect { datatable.send(:filter_records) }.to raise_error
    end

    it 'performs a simple search first' do
      expect(datatable).to receive(:simple_search).with(records)
      datatable.send(:filter_records, records)
    end

    it 'performs a composite search second' do
      expect(datatable).to receive(:composite_search).with(records)
      datatable.send(:filter_records, records)
    end

    describe '#simple_search' do
      it 'requires a records collection as argument' do
        expect { datatable.send(:simple_search) }.to raise_error
      end

      context 'no search query' do
        it 'returns original records' do
          allow(datatable).to receive(:search_query_present?) { false }
          expect(datatable.send(:simple_search, records)).to eq(records)
        end
      end

      context 'with search query' do
        before(:each) do
          datatable.params[:search][:value] = "John"
          datatable.params[:search][:regex] = "false"
        end

        it 'builds search conditions for query' do
          expect(datatable).to receive(:build_conditions_for).with('John', 'false')
          datatable.send(:simple_search, records)
        end

        it 'returns a filtered set of records' do
          results = datatable.send(:simple_search, records).map(&:username)
          expect(results).to include('johndoe')
          expect(results).not_to include('msmith')
        end
      end

      describe '#build_conditions_for' do
        before(:each) do
          datatable.params[:search][:value] = "John"
        end

        it 'calls #search_condition helper for each searchable_column' do
          allow(datatable).to receive(:search_condition) { Arel::Nodes::Grouping.new(:users) }
          datatable.send(:build_conditions_for, "John", "false")
          expect(datatable).to have_received(:search_condition).twice
        end

        it 'returns an Arel object' do
          expect(datatable.send(:build_conditions_for, 'John', 'false')).to be_a(
            Arel::Nodes::Grouping
          )
        end

        it 'can call #to_sql on returned object' do
          result = datatable.send(:build_conditions_for, "John", 'false')
          expect(result).to respond_to(:to_sql)
          expect(result.to_sql).to eq(
            "(CAST(\"users\".\"username\" AS TEXT) LIKE '%John%' OR CAST(\"users\".\"email\" AS TEXT) LIKE '%John%')"
          )
        end
      end
    end

    describe '#composite_search' do
      it 'requires a records collection as argument' do
        expect { datatable.send(:composite_search) }.to raise_error
      end

      it 'calls #aggregate_query' do
        expect(datatable).to receive(:aggregate_query)
        datatable.send(:composite_search, records)
      end

      context 'no search values in columns' do
        it 'returns original records' do
          expect(datatable.send(:composite_search, records)).to eq(records)
        end
      end

      context 'with search values in columns' do
        before(:each) do
          datatable.params[:columns]['0'][:search][:value] = 'doe'
        end

        it 'returns a filtered set of records' do
          results = datatable.send(:composite_search, records).map(&:username)
          expect(results).to include('johndoe')
          expect(results).not_to include('msmith')
        end
      end

      describe '#aggregate_query' do
        context 'columns include search query' do
          before do
            datatable.params[:columns]['0'][:search][:value] = 'doe'
            datatable.params[:columns]['1'][:search][:value] = 'example'
          end

          it 'calls #search_condition helper for each column with search query' do
            expect(datatable).to receive(:search_condition).at_least(:twice)
            datatable.send(:aggregate_query)
          end

          it 'returns an Arel object' do
            result = datatable.send(:aggregate_query)
            expect(result).to be_a(Arel::Nodes::And)
          end

          it 'can call #to_sql on returned object' do
            result = datatable.send(:aggregate_query)
            expect(result).to respond_to(:to_sql)
            expect(result.to_sql).to eq(
              "CAST(\"users\".\"username\" AS TEXT) LIKE '%doe%' AND CAST(\"users\".\"email\" AS TEXT) LIKE '%example%'"
            )
          end
        end

        context 'columns do not include search query' do
          it 'returns nil' do
            expect(datatable.send(:aggregate_query)).to be_nil
          end
        end
      end
    end

    describe '#search_condition helper method' do
      it 'can call #to_sql to resulting object' do
        result = datatable.send(:search_condition, 'User.username', 'doe')
        expect(result).to respond_to(:to_sql)
      end

      context 'column is declared as ModelName.column_name' do
        it 'returns an Arel::Nodes::Matches object with model table' do
          result = datatable.send(:search_condition, 'User.username', 'doe')
          expect(result.to_sql).to eq(
            "CAST(\"users\".\"username\" AS TEXT) LIKE '%doe%'"
          )
        end
      end

      context 'column is declared as aliased_join_table_name.column_name' do
        it 'returns an Arel::Nodes::Matches object with aliased join table' do
          result = datatable.send(:search_condition,
                                  'aliased_join_table.unexistent_column',
                                  'doe'
                                 )
          expect(result.to_sql).to eq(
            "CAST(\"aliased_join_table\".\"unexistent_column\" AS TEXT) LIKE '%doe%'"
          )
        end
      end
    end

    describe '#typecast helper method' do
      let(:view) { double('view', :params => sample_params) }
      let(:datatable) { AjaxDatatablesRails::Base.new(view) }

      it 'returns VARCHAR if :db_adapter is :pg' do
        allow_any_instance_of(AjaxDatatablesRails::Configuration).to receive(:db_adapter) { :pg }
        expect(datatable.send(:typecast)).to eq('VARCHAR')
      end

      it 'returns VARCHAR if :db_adapter is :postgre' do
        allow_any_instance_of(AjaxDatatablesRails::Configuration).to receive(:db_adapter) { :postgre }
        expect(datatable.send(:typecast)).to eq('VARCHAR')
      end

      it 'returns CHAR if :db_adapter is :mysql2' do
        allow_any_instance_of(AjaxDatatablesRails::Configuration).to receive(:db_adapter) { :mysql2 }
        expect(datatable.send(:typecast)).to eq('CHAR')
      end

      it 'returns CHAR if :db_adapter is :mysql' do
        allow_any_instance_of(AjaxDatatablesRails::Configuration).to receive(:db_adapter) { :mysql }
        expect(datatable.send(:typecast)).to eq('CHAR')
      end

      it 'returns TEXT if :db_adapter is :sqlite' do
        allow_any_instance_of(AjaxDatatablesRails::Configuration).to receive(:db_adapter) { :sqlite }
        expect(datatable.send(:typecast)).to eq('TEXT')
      end

      it 'returns TEXT if :db_adapter is :sqlite3' do
        allow_any_instance_of(AjaxDatatablesRails::Configuration).to receive(:db_adapter) { :sqlite3 }
        expect(datatable.send(:typecast)).to eq('TEXT')
      end
    end
  end
end
