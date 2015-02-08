require 'spec_helper'

describe AjaxDatatablesRails::ORM::ActiveRecord do
  context 'Private API' do
    let(:view) { double('view', params: sample_params) }
    let(:datatable) { SampleDatatable.new(view) }

    before(:each) do
      User.create(username: 'johndoe', email: 'johndoe@example.com')
      User.create(username: 'msmith', email: 'mary.smith@example.com')
    end

    after(:each) do
      User.destroy_all
    end

    describe 'fetch records' do
      it 'calls #get_raw_records' do
        expect(datatable).to receive(:get_raw_records) { User.all }
        datatable.send(:fetch_records)
      end

      it 'returns a collection of records' do
        expect(datatable).to receive(:get_raw_records) { User.all }
        expect(datatable.send(:fetch_records)).to be_a(ActiveRecord::Relation)
      end
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
          end

          it 'builds search conditions for query' do
            expect(datatable).to receive(:build_conditions_for).with('John')
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
            datatable.send(:build_conditions_for, "John")
            expect(datatable).to have_received(:search_condition).twice
          end

          it 'returns an Arel object' do
            expect(datatable.send(:build_conditions_for, 'John')).to be_a(
              Arel::Nodes::Grouping
            )
          end

          it 'can call #to_sql on returned object' do
            result = datatable.send(:build_conditions_for, "John")
            expect(result).to respond_to(:to_sql)
            expect(result.to_sql).to eq(
              "(CAST(\"users\".\"username\" AS VARCHAR) LIKE '%John%' OR CAST(\"users\".\"email\" AS VARCHAR) LIKE '%John%')"
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
      end
    end

    describe 'sort records' do
    end

    describe 'paginate records' do
    end
  end
end
