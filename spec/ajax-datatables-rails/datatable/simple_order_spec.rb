require 'spec_helper'

describe AjaxDatatablesRails::Datatable::SimpleOrder do

  let(:options) { ActiveSupport::HashWithIndifferentAccess.new({'column'=>'1', 'dir'=>'desc'}) }
  let(:simple_order) { AjaxDatatablesRails::Datatable::SimpleOrder.new(nil, options) }

  describe 'option methods' do
    it 'sql query' do
      expect(simple_order.query('firstname')).to eq('firstname DESC')
    end
  end

  describe 'option methods with nulls last' do
    before { AjaxDatatablesRails.config.sort_nulls_last = true }
    after { AjaxDatatablesRails.config.sort_nulls_last = false }

    it 'sql query' do
      expect(simple_order.query('firstname')).to eq('CASE WHEN firstname IS NULL THEN 1 ELSE 0 END, firstname DESC')
    end
  end
end
