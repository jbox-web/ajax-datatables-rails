require 'spec_helper'

describe AjaxDatatablesRails::Datatable::Datatable do

  let(:datatable) { ComplexDatatable.new(sample_params).datatable }

  describe 'order methods' do
    let(:order_option) { {'0'=>{'column'=>'0', 'dir'=>'asc'}, '1'=>{'column'=>'1', 'dir'=>'desc'}} }

    it 'should be orderable' do
      expect(datatable.orderable?).to eq(true)
    end

    it 'should not be orderable' do
      datatable.options[:order] = nil
      expect(datatable.orderable?).to eq(false)
    end

    it 'should have 2 orderable columns' do
      datatable.options[:order] = order_option
      expect(datatable.orders.count).to eq(2)
    end

    it 'first column ordered by ASC' do
      datatable.options[:order] = order_option
      expect(datatable.orders.first.direction).to eq('ASC')
    end

    it 'first column ordered by DESC' do
      datatable.options[:order] = order_option
      expect(datatable.orders.last.direction).to eq('DESC')
    end

    it 'child class' do
      expect(datatable.orders.first).to be_a(AjaxDatatablesRails::Datatable::SimpleOrder)
    end
  end

  describe 'search methods' do
    it 'should be searchable' do
      datatable.options[:search][:value] = 'atom'
      expect(datatable.searchable?).to eq(true)
    end

    it 'should not be searchable' do
      datatable.options[:search][:value] = nil
      expect(datatable.searchable?).to eq(false)
    end

    it 'child class' do
      expect(datatable.search).to be_a(AjaxDatatablesRails::Datatable::SimpleSearch)
    end
  end

  describe 'columns methods' do
    it 'should have 4 columns' do
      expect(datatable.columns.count).to eq(6)
    end

    it 'child class' do
      expect(datatable.columns.first).to be_a(AjaxDatatablesRails::Datatable::Column)
    end
  end

  describe 'option methods' do
    describe '#paginate?' do
      it {
        expect(datatable.paginate?).to be(true)
      }
    end

    describe '#per_page' do
      context 'when params[:length] is missing' do
        it 'defaults to 10' do
          expect(datatable.per_page).to eq(10)
        end
      end

      context 'when params[:length] is passed' do
        let(:datatable) { ComplexDatatable.new({ length: '20' }).datatable }

        it 'matches the value on view params[:length]' do
          expect(datatable.per_page).to eq(20)
        end
      end
    end

    describe '#offset' do
      context 'when params[:start] is missing' do
        it 'defaults to 0' do
          expect(datatable.offset).to eq(0)
        end
      end

      context 'when params[:start] is passed' do
        let(:datatable) { ComplexDatatable.new({ start: '11' }).datatable }

        it 'matches the value on view params[:start]' do
          expect(datatable.offset).to eq(11)
        end
      end
    end

    describe '#page' do
      let(:datatable) { ComplexDatatable.new({ start: '11' }).datatable }

      it 'calculates page number from params[:start] and #per_page' do
        expect(datatable.page).to eq(2)
      end
    end
  end
end
