# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AjaxDatatablesRails::Base do

  describe 'an instance' do
    it 'requires a hash of params' do
      expect { described_class.new }.to raise_error ArgumentError
    end

    it 'accepts an options hash' do
      datatable = described_class.new(sample_params, foo: 'bar')
      expect(datatable.options).to eq(foo: 'bar')
    end
  end

  describe 'User API' do
    describe '#view_columns' do
      context 'when method is not defined by the user' do
        it 'raises an error' do
          datatable = described_class.new(sample_params)
          expect { datatable.view_columns }.to raise_error NotImplementedError
        end
      end

      context 'child class implements view_columns' do
        it 'expects a hash based defining columns' do
          datatable = ComplexDatatable.new(sample_params)
          expect(datatable.view_columns).to be_a(Hash)
        end
      end
    end

    describe '#get_raw_records' do
      context 'when method is not defined by the user' do
        it 'raises an error' do
          datatable = described_class.new(sample_params)
          expect { datatable.get_raw_records }.to raise_error NotImplementedError
        end
      end
    end

    describe '#data' do
      context 'when method is not defined by the user' do
        it 'raises an error' do
          datatable = described_class.new(sample_params)
          expect { datatable.data }.to raise_error NotImplementedError
        end
      end

      context 'when data is defined as a hash' do
        let(:datatable) { ComplexDatatable.new(sample_params) }

        it 'returns an array of hashes' do
          create_list(:user, 5)
          expect(datatable.data).to be_a(Array)
          expect(datatable.data.size).to eq 5
          item = datatable.data.first
          expect(item).to be_a(Hash)
        end

        it 'htmls escape data' do
          create(:user, first_name: 'Name "><img src=x onerror=alert("first_name")>', last_name: 'Name "><img src=x onerror=alert("last_name")>')
          data = datatable.send(:sanitize_data, datatable.data)
          item = data.first
          expect(item[:first_name]).to eq 'Name &quot;&gt;&lt;img src=x onerror=alert(&quot;first_name&quot;)&gt;'
          expect(item[:last_name]).to eq 'Name &quot;&gt;&lt;img src=x onerror=alert(&quot;last_name&quot;)&gt;'
        end
      end

      context 'when data is defined as a array' do
        let(:datatable) { ComplexDatatableArray.new(sample_params) }

        it 'returns an array of arrays' do
          create_list(:user, 5)
          expect(datatable.data).to be_a(Array)
          expect(datatable.data.size).to eq 5
          item = datatable.data.first
          expect(item).to be_a(Array)
        end

        it 'htmls escape data' do
          create(:user, first_name: 'Name "><img src=x onerror=alert("first_name")>', last_name: 'Name "><img src=x onerror=alert("last_name")>')
          data = datatable.send(:sanitize_data, datatable.data)
          item = data.first
          expect(item[2]).to eq 'Name &quot;&gt;&lt;img src=x onerror=alert(&quot;first_name&quot;)&gt;'
          expect(item[3]).to eq 'Name &quot;&gt;&lt;img src=x onerror=alert(&quot;last_name&quot;)&gt;'
        end
      end
    end
  end

  describe 'ORM API' do
    context 'when ORM is not implemented' do
      let(:datatable) { AjaxDatatablesRails::Base.new(sample_params) }

      describe '#fetch_records' do
        it 'raises an error if it does not include an ORM module' do
          expect { datatable.fetch_records }.to raise_error NotImplementedError
        end
      end

      describe '#filter_records' do
        it 'raises an error if it does not include an ORM module' do
          expect { datatable.filter_records([]) }.to raise_error NotImplementedError
        end
      end

      describe '#sort_records' do
        it 'raises an error if it does not include an ORM module' do
          expect { datatable.sort_records([]) }.to raise_error NotImplementedError
        end
      end

      describe '#paginate_records' do
        it 'raises an error if it does not include an ORM module' do
          expect { datatable.paginate_records([]) }.to raise_error NotImplementedError
        end
      end
    end

    context 'when ORM is implemented' do
      describe 'it allows method override' do
        let(:datatable) do
          datatable = Class.new(ComplexDatatable) do
            def filter_records(records)
              raise NotImplementedError.new('FOO')
            end

            def sort_records(records)
              raise NotImplementedError.new('FOO')
            end

            def paginate_records(records)
              raise NotImplementedError.new('FOO')
            end
          end
          datatable.new(sample_params)
        end

        describe '#fetch_records' do
          it 'calls #get_raw_records' do
            expect(datatable).to receive(:get_raw_records) { User.all }
            datatable.fetch_records
          end

          it 'returns a collection of records' do
            expect(datatable).to receive(:get_raw_records) { User.all }
            expect(datatable.fetch_records).to be_a(ActiveRecord::Relation)
          end
        end

        describe '#filter_records' do
          it {
            expect { datatable.filter_records([]) }.to raise_error(NotImplementedError).with_message('FOO')
          }
        end

        describe '#sort_records' do
          it {
            expect { datatable.sort_records([]) }.to raise_error(NotImplementedError).with_message('FOO')
          }
        end

        describe '#paginate_records' do
          it {
            expect { datatable.paginate_records([]) }.to raise_error(NotImplementedError).with_message('FOO')
          }
        end
      end
    end
  end

  describe 'JSON format' do
    describe '#as_json' do
      let(:datatable) { ComplexDatatable.new(sample_params) }

      it 'returns a hash' do
        create_list(:user, 5)
        data = datatable.as_json
        expect(data[:recordsTotal]).to eq 5
        expect(data[:recordsFiltered]).to eq 5
        expect(data[:data]).to be_a(Array)
        expect(data[:data].size).to eq 5
      end

      context 'with additional_data' do
        it 'returns a hash' do
          create_list(:user, 5)
          expect(datatable).to receive(:additional_data) { { foo: 'bar' } }
          data = datatable.as_json
          expect(data[:recordsTotal]).to eq 5
          expect(data[:recordsFiltered]).to eq 5
          expect(data[:data]).to be_a(Array)
          expect(data[:data].size).to eq 5
          expect(data[:foo]).to eq 'bar'
        end
      end
    end
  end

  describe 'User helper methods' do
    describe '#column_id' do
      let(:datatable) { ComplexDatatable.new(sample_params) }

      it 'returns column id from view_columns hash' do
        expect(datatable.column_id(:username)).to eq(0)
        expect(datatable.column_id('username')).to eq(0)
      end
    end

    describe '#column_data' do
      let(:datatable) { ComplexDatatable.new(sample_params) }
      before { datatable.params[:columns]['0'][:search][:value] = 'doe' }

      it 'returns column data from params' do
        expect(datatable.column_data(:username)).to eq('doe')
        expect(datatable.column_data('username')).to eq('doe')
      end
    end
  end
end
