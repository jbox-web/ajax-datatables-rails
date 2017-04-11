require 'spec_helper'

describe AjaxDatatablesRails::Datatable::SimpleSearch do

  let(:options) { ActiveSupport::HashWithIndifferentAccess.new({'value'=>'search value', 'regex'=>'true'}) }
  let(:simple_search) { AjaxDatatablesRails::Datatable::SimpleSearch.new(options) }

  describe 'option methods' do
    it 'regexp?' do
      expect(simple_search.regexp?).to be(true)
    end

    it 'value' do
      expect(simple_search.value).to eq('search value')
    end
  end
end
