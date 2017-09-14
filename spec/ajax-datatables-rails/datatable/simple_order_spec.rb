require 'spec_helper'

describe AjaxDatatablesRails::Datatable::SimpleOrder do
  let(:datatable) { ReallyComplexDatatable.new(double('view', params: sample_params)) }
  let(:sorted_datatable) { SortedDatatable.new(double('view', params: sample_params)) }
  let(:options) { ActiveSupport::HashWithIndifferentAccess.new({'column'=>'1', 'dir'=>'desc'}) }
  let(:simple_order) { AjaxDatatablesRails::Datatable::SimpleOrder.new(datatable, options) }

  describe 'option methods' do
    it 'sql query' do
      expect(simple_order.query('firstname')).to eq('firstname DESC')
    end
  end

  describe 'option methods with nulls last' do
    describe 'using global option' do
      before { AjaxDatatablesRails.config.nulls_last = true }
      after  { AjaxDatatablesRails.config.nulls_last = false }
    
      it 'sql query' do
        expect(simple_order.query('email')).to eq(
        'CASE WHEN email IS NULL THEN 1 ELSE 0 END, email DESC'
        )
      end
    end

    describe 'using column option' do
      let(:simple_order_with_nulls_last) { AjaxDatatablesRails::Datatable::SimpleOrder.new(sorted_datatable, options) }

      it 'sql query' do
        expect(simple_order_with_nulls_last.query('email')).to eq(
        'CASE WHEN email IS NULL THEN 1 ELSE 0 END, email DESC'
        )
      end
    end
  end
end
