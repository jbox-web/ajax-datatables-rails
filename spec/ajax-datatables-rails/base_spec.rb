require 'spec_helper'

describe AjaxDatatablesRails::Base do

  describe 'an instance' do
    it 'requires a hash of params' do
      expect { described_class.new }.to raise_error ArgumentError
    end

    it 'accepts an options hash' do
      datatable = described_class.new(sample_params, foo: 'bar')
      expect(datatable.options).to eq(foo: 'bar')
    end
  end

  context 'Public API' do
    describe '#view_columns' do
      it 'raises an error if not defined by the user' do
        datatable = described_class.new(sample_params)
        expect { datatable.view_columns }.to raise_error NotImplementedError
      end

      context 'child class implements view_columns' do
        it 'expects a hash based defining columns' do
          datatable = ComplexDatatable.new(sample_params)
          expect(datatable.view_columns).to be_a(Hash)
        end
      end
    end

    describe '#get_raw_records' do
      it 'raises an error if not defined by the user' do
        datatable = described_class.new(sample_params)
        expect { datatable.get_raw_records }.to raise_error NotImplementedError
      end
    end

    describe '#data' do
      it 'raises an error if not defined by the user' do
        datatable = described_class.new(sample_params)
        expect { datatable.data }.to raise_error NotImplementedError
      end

      context 'when data is defined as a hash' do
        let(:datatable) { ComplexDatatable.new(sample_params) }

        it 'should return an array of hashes' do
          create_list(:user, 5)
          expect(datatable.data).to be_a(Array)
          expect(datatable.data.size).to eq 5
          item = datatable.data.first
          expect(item).to be_a(Hash)
        end

        it 'should html escape data' do
          create(:user, first_name: 'Name "><img src=x onerror=alert("first_name")>', last_name: 'Name "><img src=x onerror=alert("last_name")>')
          data = datatable.send(:sanitize, datatable.data)
          item = data.first
          expect(item[:first_name]).to eq 'Name &quot;&gt;&lt;img src=x onerror=alert(&quot;first_name&quot;)&gt;'
          expect(item[:last_name]).to eq 'Name &quot;&gt;&lt;img src=x onerror=alert(&quot;last_name&quot;)&gt;'
        end
      end

      context 'when data is defined as a array' do
        let(:datatable) { ComplexDatatableArray.new(sample_params) }

        it 'should return an array of arrays' do
          create_list(:user, 5)
          expect(datatable.data).to be_a(Array)
          expect(datatable.data.size).to eq 5
          item = datatable.data.first
          expect(item).to be_a(Array)
        end

        it 'should html escape data' do
          create(:user, first_name: 'Name "><img src=x onerror=alert("first_name")>', last_name: 'Name "><img src=x onerror=alert("last_name")>')
          data = datatable.send(:sanitize, datatable.data)
          item = data.first
          expect(item[2]).to eq 'Name &quot;&gt;&lt;img src=x onerror=alert(&quot;first_name&quot;)&gt;'
          expect(item[3]).to eq 'Name &quot;&gt;&lt;img src=x onerror=alert(&quot;last_name&quot;)&gt;'
        end
      end
    end

    describe '#as_json' do
      let(:datatable) { ComplexDatatable.new(sample_params) }

      it 'should return a hash' do
        create_list(:user, 5)
        data = datatable.as_json
        expect(data[:recordsTotal]).to eq 5
        expect(data[:recordsFiltered]).to eq 5
        expect(data[:data]).to be_a(Array)
        expect(data[:data].size).to eq 5
      end

      context 'with additional_data' do
        it 'should return a hash' do
          create_list(:user, 5)
          expect(datatable).to receive(:additional_data){ { foo: 'bar' } }
          data = datatable.as_json
          expect(data[:recordsTotal]).to eq 5
          expect(data[:recordsFiltered]).to eq 5
          expect(data[:data]).to be_a(Array)
          expect(data[:data].size).to eq 5
          expect(data[:foo]).to eq 'bar'
        end
      end
    end

    describe '#filter_records' do
      let(:records) { User.all }

      let(:datatable) do
        datatable = Class.new(ComplexDatatable) do
          def filter_records(records)
            raise NotImplementedError
          end
        end
        datatable.new(sample_params)
      end

      it 'should allow method override' do
        expect { datatable.filter_records(records) }.to raise_error(NotImplementedError)
      end
    end

    describe '#sort_records' do
      let(:records) { User.all }

      let(:datatable) do
        datatable = Class.new(ComplexDatatable) do
          def sort_records(records)
            raise NotImplementedError
          end
        end
        datatable.new(sample_params)
      end

      it 'should allow method override' do
        expect { datatable.sort_records(records) }.to raise_error(NotImplementedError)
      end
    end

    describe '#paginate_records' do
      let(:records) { User.all }

      let(:datatable) do
        datatable = Class.new(ComplexDatatable) do
          def paginate_records(records)
            raise NotImplementedError
          end
        end
        datatable.new(sample_params)
      end

      it 'should allow method override' do
        expect { datatable.paginate_records(records) }.to raise_error(NotImplementedError)
      end
    end
  end


  context 'Private API' do
    context 'when orm is not implemented' do
      let(:datatable) { AjaxDatatablesRails::Base.new(sample_params) }

      describe '#fetch_records' do
        it 'raises an error if it does not include an ORM module' do
          expect { datatable.fetch_records }.to raise_error NoMethodError
        end
      end

      describe '#filter_records' do
        it 'raises an error if it does not include an ORM module' do
          expect { datatable.filter_records }.to raise_error NoMethodError
        end
      end

      describe '#sort_records' do
        it 'raises an error if it does not include an ORM module' do
          expect { datatable.sort_records }.to raise_error NoMethodError
        end
      end

      describe '#paginate_records' do
        it 'raises an error if it does not include an ORM module' do
          expect { datatable.paginate_records }.to raise_error NoMethodError
        end
      end
    end

    describe 'helper methods' do
      describe '#offset' do
        it 'defaults to 0' do
          datatable = described_class.new({})
          expect(datatable.datatable.send(:offset)).to eq(0)
        end

        it 'matches the value on view params[:start]' do
          datatable = described_class.new({ start: '11' })
          expect(datatable.datatable.send(:offset)).to eq(11)
        end
      end

      describe '#page' do
        it 'calculates page number from params[:start] and #per_page' do
          datatable = described_class.new({ start: '11' })
          expect(datatable.datatable.send(:page)).to eq(2)
        end
      end

      describe '#per_page' do
        it 'defaults to 10' do
          datatable = described_class.new(sample_params)
          expect(datatable.datatable.send(:per_page)).to eq(10)
        end

        it 'matches the value on view params[:length]' do
          other_view = { length: 20 }
          datatable = described_class.new(other_view)
          expect(datatable.datatable.send(:per_page)).to eq(20)
        end
      end
    end
  end
end
