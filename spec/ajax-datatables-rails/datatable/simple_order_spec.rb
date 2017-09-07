require 'spec_helper'

describe AjaxDatatablesRails::Datatable::SimpleOrder do

  let(:datatable) { ReallyComplexDatatable.new(double('view', params: sample_params)) }
  let(:options) { ActiveSupport::HashWithIndifferentAccess.new({'column'=>'1', 'dir'=>'desc'}) }
  let(:simple_order) { AjaxDatatablesRails::Datatable::SimpleOrder.new(datatable, options) }

  describe 'option methods' do
    it 'sql query' do
      expect(simple_order.query('firstname')).to eq('firstname DESC')
    end
  end

  describe 'option methods with nulls last' do
    let(:column) { datatable.datatable.columns.first }

    describe 'with global option' do
      before { AjaxDatatablesRails.config.sort_nulls_last = true }
      after  { AjaxDatatablesRails.config.sort_nulls_last = false }

      it 'sql query' do
        expect(simple_order.query('firstname')).to eq('CASE WHEN firstname IS NULL THEN 1 ELSE 0 END, firstname DESC')
      end
    end
    
    describe 'with column option' do

      it 'sql query' do
        binding.pry
        expect(simple_order.query('firstname')).to eq('CASE WHEN firstname IS NULL THEN 1 ELSE 0 END, firstname DESC')
      end
    end

  end
end
