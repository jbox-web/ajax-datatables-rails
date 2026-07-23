# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AjaxDatatablesRails::Datatable::Datatable do

  let(:datatable) { ComplexDatatable.new(sample_params).datatable }
  let(:datatable_json) { ComplexDatatable.new(sample_params_json).datatable }
  let(:order_option) { { '0' => { 'column' => '0', 'dir' => 'asc' }, '1' => { 'column' => '1', 'dir' => 'desc' } } }
  let(:order_option_json) { [{ 'column' => '0', 'dir' => 'asc' }, { 'column' => '1', 'dir' => 'desc' }] }

  shared_examples 'order methods' do
    it 'is orderable' do
      expect(datatable.orderable?).to be(true)
    end

    it 'is not orderable' do
      datatable.options[:order] = nil
      expect(datatable.orderable?).to be(false)
    end

    it 'has 2 orderable columns' do
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

  shared_examples 'columns methods' do
    it 'has 8 columns' do
      expect(datatable.columns.count).to eq(8)
    end

    it 'child class' do
      expect(datatable.columns.first).to be_a(AjaxDatatablesRails::Datatable::Column)
    end
  end

  describe 'with query params' do
    it_behaves_like 'order methods'
    it_behaves_like 'columns methods'
  end

  describe 'with json params' do
    let(:order_option) { order_option_json }
    let(:datatable) { datatable_json }

    it_behaves_like 'order methods'
    it_behaves_like 'columns methods'
  end

  describe '#order_by' do
    before { datatable.options[:order] = order_option }

    it 'finds the SimpleOrder matching the given attribute' do
      expect(datatable.order_by(:direction, 'ASC')).to be(datatable.orders.first)
    end

    it 'returns nil when no order matches' do
      expect(datatable.order_by(:direction, 'NOPE')).to be_nil
    end
  end

  describe '#get_param' do
    context 'when the requested param is absent' do
      let(:datatable) { ComplexDatatable.new({}).datatable }

      it 'returns no columns' do
        expect(datatable.columns).to eq([])
      end

      it 'returns no orders' do
        expect(datatable.orders).to eq([])
      end
    end
  end

  describe 'search methods' do
    it 'is searchable' do
      datatable.options[:search][:value] = 'atom'
      expect(datatable.searchable?).to be(true)
    end

    it 'is not searchable' do
      datatable.options[:search][:value] = nil
      expect(datatable.searchable?).to be(false)
    end

    it 'child class' do
      expect(datatable.search).to be_a(AjaxDatatablesRails::Datatable::SimpleSearch)
    end
  end

  describe 'option methods' do
    describe '#paginate?' do
      it {
        expect(datatable.paginate?).to be(true)
      }

      context 'when params[:length] == -1 (show all)' do
        let(:datatable) { ComplexDatatable.new({ length: '-1' }).datatable }

        it 'is false' do
          expect(datatable.paginate?).to be(false)
        end
      end
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

      context 'when params[:length] is present but blank' do
        let(:datatable) { ComplexDatatable.new({ length: '' }).datatable }

        it 'defaults to 10 instead of collapsing to 0' do
          expect(datatable.per_page).to eq(10)
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

      context 'when per_page is 0 (params[:length] == 0)' do
        let(:datatable) { ComplexDatatable.new({ length: '0' }).datatable }

        it 'does not raise ZeroDivisionError and falls back to 1' do
          expect { datatable.page }.to_not raise_error
          expect(datatable.page).to eq(1)
        end
      end
    end

  end
end
