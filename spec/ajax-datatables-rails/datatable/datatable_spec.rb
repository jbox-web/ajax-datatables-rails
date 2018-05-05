require 'spec_helper'

describe AjaxDatatablesRails::Datatable::Datatable do

  let(:datatable) { ComplexDatatable.new(sample_params).datatable }
  let(:order_option) { {'0'=>{'column'=>'0', 'dir'=>'asc'}, '1'=>{'column'=>'1', 'dir'=>'desc'}} }

  describe 'order methods' do
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
    before :each do
      datatable.options[:start] = '50'
      datatable.options[:length] = '15'
    end

    it 'paginate?' do
      expect(datatable.paginate?).to be(true)
    end

    it 'offset' do
      expect(datatable.offset).to eq(50)
    end

    it 'page' do
      expect(datatable.page).to eq(4)
    end

    it 'per_page' do
      expect(datatable.per_page).to eq(15)
    end
  end
end
