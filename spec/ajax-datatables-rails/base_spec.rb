require 'spec_helper'

describe AjaxDatatablesRails::Base do
  describe 'an instance' do
    let(:view) { double('view', params: sample_params) }

    it 'requires a view_context' do
      expect { AjaxDatatablesRails::Base.new }.to raise_error
    end

    it 'accepts an options hash' do
      datatable = AjaxDatatablesRails::Base.new(view, :foo => 'bar')
      expect(datatable.options).to eq(:foo => 'bar')
    end
  end

  context 'Public API' do
    let(:view) { double('view', params: sample_params) }
    let(:datatable) { AjaxDatatablesRails::Base.new(view) }

    describe '#view_columns' do
      it 'raises an error if not defined by the user' do
        expect { datatable.view_columns }.to raise_error
      end

      context 'child class implements view_columns' do
        let(:datatable) { SampleDatatable.new(view) }

        it 'expects an array of columns displayed in the html view' do
          expect(datatable.view_columns).to be_a(Array)
        end
      end
    end

    describe '#data' do
      it 'raises an error if not defined by the user' do
        expect { datatable.data }.to raise_error
      end

      context 'child class implements data' do
        let(:datatable) { SampleDatatable.new(view) }

        it 'can return an array of hashes' do
          allow(datatable).to receive(:data) { [{}, {}] }
          expect(datatable.data).to be_a(Array)
          item = datatable.data.first
          expect(item).to be_a(Hash)
        end

        it 'can return an array of arrays' do
          allow(datatable).to receive(:data) { [[], []] }
          expect(datatable.data).to be_a(Array)
          item = datatable.data.first
          expect(item).to be_a(Array)
        end
      end

    end

    describe '#get_raw_records' do
      it 'raises an error if not defined by the user' do
        expect { datatable.get_raw_records }.to raise_error
      end
    end
  end

  context 'Private API' do
    let(:view) { double('view', params: sample_params) }
    let(:datatable) { SampleDatatable.new(view) }

    before(:each) do
      allow_any_instance_of(AjaxDatatablesRails::Configuration).to receive(:orm) { nil }
    end

    describe 'fetch records' do
      it 'raises an error if it does not include an ORM module' do
        expect { datatable.send(:fetch_records) }.to raise_error
      end
    end

    describe 'filter records' do
      it 'raises an error if it does not include an ORM module' do
        expect { datatable.send(:filter_records) }.to raise_error
      end
    end

    describe 'sort records' do
      it 'raises an error if it does not include an ORM module' do
        expect { datatable.send(:sort_records) }.to raise_error
      end
    end

    describe 'paginate records' do
      it 'raises an error if it does not include an ORM module' do
        expect { datatable.send(:paginate_records) }.to raise_error
      end
    end
  end
end
