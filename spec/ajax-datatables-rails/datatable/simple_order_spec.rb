require 'spec_helper'

describe AjaxDatatablesRails::Datatable::SimpleOrder do

  let(:options) { ActiveSupport::HashWithIndifferentAccess.new({'column'=>'1', 'dir'=>'desc'}) }
  let(:simple_order) { AjaxDatatablesRails::Datatable::SimpleOrder.new(nil, options) }

  describe 'option methods' do
    it 'sql query' do
      expect(simple_order.query('firstname')).to eq('firstname DESC')
    end
  end
end
