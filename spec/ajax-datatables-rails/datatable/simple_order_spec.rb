require 'spec_helper'

describe AjaxDatatablesRails::Datatable::SimpleOrder do

  describe 'option methods' do
    let(:options) { ActiveSupport::HashWithIndifferentAccess.new({'column'=>'1', 'dir'=>'desc'}) }
    let(:simple_order) { AjaxDatatablesRails::Datatable::SimpleOrder.new(nil, options) }

    it 'sql query' do
      expect(simple_order.query('firstname')).to eq('firstname DESC')
    end
  end

  describe 'option methods with nulls last' do
    let(:options) { ActiveSupport::HashWithIndifferentAccess.new({'column'=>'1', 'dir'=>'desc', 'nulls_last'=>true}) }
    let(:simple_order) { AjaxDatatablesRails::Datatable::SimpleOrder.new(nil, options) }

    it 'sql query' do
      expect(simple_order.query('firstname')).to eq('CASE WHEN firstname IS NULL THEN 1 ELSE 0 END, firstname DESC')
    end
  end
end
