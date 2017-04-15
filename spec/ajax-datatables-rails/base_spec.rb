require 'spec_helper'

describe AjaxDatatablesRails::Base do

  describe 'an instance' do
    let(:view) { double('view', params: sample_params) }

    it 'requires a view_context' do
      expect { AjaxDatatablesRails::Base.new }.to raise_error ArgumentError
    end

    it 'accepts an options hash' do
      datatable = AjaxDatatablesRails::Base.new(view, foo: 'bar')
      expect(datatable.options).to eq(foo: 'bar')
    end
  end

  context 'Public API' do
    let(:view) { double('view', params: sample_params) }
    let(:datatable) { AjaxDatatablesRails::Base.new(view) }

    describe '#view_columns' do
      it 'raises an error if not defined by the user' do
        expect { datatable.view_columns }.to raise_error AjaxDatatablesRails::NotImplemented
      end

      context 'child class implements view_columns' do
        it 'expects an array based defining columns' do
          datatable = SampleDatatable.new(view)
          expect(datatable.view_columns).to be_a(Array)
        end

        it 'expects a hash based defining columns' do
          datatable = ComplexDatatable.new(view)
          expect(datatable.view_columns).to be_a(Hash)
        end
      end
    end

    describe '#get_raw_records' do
      it 'raises an error if not defined by the user' do
        expect { datatable.get_raw_records }.to raise_error AjaxDatatablesRails::NotImplemented
      end
    end

    describe '#data' do
      it 'raises an error if not defined by the user' do
        expect { datatable.data }.to raise_error AjaxDatatablesRails::NotImplemented
      end

      context 'when data is defined as a hash' do
        it 'should return an array of hashes' do
          datatable = ComplexDatatableHash.new(view)
          create_list(:user, 5)
          expect(datatable.data).to be_a(Array)
          expect(datatable.data.size).to eq 5
          item = datatable.data.first
          expect(item).to be_a(Hash)
        end

        it 'should html escape data' do
          datatable = ComplexDatatableHash.new(view)
          create(:user, first_name: 'Name "><img src=x onerror=alert("first_name")>', last_name: 'Name "><img src=x onerror=alert("last_name")>')
          data = datatable.send(:sanitize, datatable.data)
          item = data.first
          expect(item[:first_name]).to eq 'Name &quot;&gt;&lt;img src=x onerror=alert(&quot;first_name&quot;)&gt;'
          expect(item[:last_name]).to eq 'Name &quot;&gt;&lt;img src=x onerror=alert(&quot;last_name&quot;)&gt;'
        end
      end

      context 'when data is defined as a array' do
        it 'should return an array of arrays' do
          datatable = ComplexDatatableArray.new(view)
          create_list(:user, 5)
          expect(datatable.data).to be_a(Array)
          expect(datatable.data.size).to eq 5
          item = datatable.data.first
          expect(item).to be_a(Array)
        end

        it 'should html escape data' do
          datatable = ComplexDatatableArray.new(view)
          create(:user, first_name: 'Name "><img src=x onerror=alert("first_name")>', last_name: 'Name "><img src=x onerror=alert("last_name")>')
          data = datatable.send(:sanitize, datatable.data)
          item = data.first
          expect(item[2]).to eq 'Name &quot;&gt;&lt;img src=x onerror=alert(&quot;first_name&quot;)&gt;'
          expect(item[3]).to eq 'Name &quot;&gt;&lt;img src=x onerror=alert(&quot;last_name&quot;)&gt;'
        end
      end
    end

    describe '#as_json' do
      it 'should return a hash' do
        datatable = ComplexDatatableHash.new(view)
        create_list(:user, 5)
        data = datatable.as_json
        expect(data[:recordsTotal]).to eq 5
        expect(data[:recordsFiltered]).to eq 5
        expect(data[:data]).to be_a(Array)
        expect(data[:data].size).to eq 5
      end

      context 'with additional_datas' do
        it 'should return a hash' do
          datatable = ComplexDatatableHash.new(view)
          create_list(:user, 5)
          expect(datatable).to receive(:additional_datas){ { foo: 'bar' } }
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


  context 'Private API' do

    let(:view) { double('view', params: sample_params) }
    let(:datatable) { ComplexDatatable.new(view) }

    before(:each) do
      allow_any_instance_of(AjaxDatatablesRails::Configuration).to receive(:orm) { nil }
    end

    describe '#fetch_records' do
      it 'raises an error if it does not include an ORM module' do
        expect { datatable.send(:fetch_records) }.to raise_error NoMethodError
      end
    end

    describe '#filter_records' do
      it 'raises an error if it does not include an ORM module' do
        expect { datatable.send(:filter_records) }.to raise_error NoMethodError
      end
    end

    describe '#sort_records' do
      it 'raises an error if it does not include an ORM module' do
        expect { datatable.send(:sort_records) }.to raise_error NoMethodError
      end
    end

    describe '#paginate_records' do
      it 'raises an error if it does not include an ORM module' do
        expect { datatable.send(:paginate_records) }.to raise_error NoMethodError
      end
    end

    describe 'helper methods' do
      describe '#offset' do
        it 'defaults to 0' do
          default_view = double('view', params: {})
          datatable = AjaxDatatablesRails::Base.new(default_view)
          expect(datatable.datatable.send(:offset)).to eq(0)
        end

        it 'matches the value on view params[:start] minus 1' do
          paginated_view = double('view', params: { start: '11' })
          datatable = AjaxDatatablesRails::Base.new(paginated_view)
          expect(datatable.datatable.send(:offset)).to eq(10)
        end
      end

      describe '#page' do
        it 'calculates page number from params[:start] and #per_page' do
          paginated_view = double('view', params: { start: '11' })
          datatable = AjaxDatatablesRails::Base.new(paginated_view)
          expect(datatable.datatable.send(:page)).to eq(2)
        end
      end

      describe '#per_page' do
        it 'defaults to 10' do
          datatable = AjaxDatatablesRails::Base.new(view)
          expect(datatable.datatable.send(:per_page)).to eq(10)
        end

        it 'matches the value on view params[:length]' do
          other_view = double('view', params: { length: 20 })
          datatable = AjaxDatatablesRails::Base.new(other_view)
          expect(datatable.datatable.send(:per_page)).to eq(20)
        end
      end
    end
  end
end
