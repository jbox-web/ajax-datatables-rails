# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AjaxDatatablesRails::Datatable::SimpleSearch do

  let(:options) { ActiveSupport::HashWithIndifferentAccess.new({ 'value' => 'search value', 'regex' => 'true' }) }
  let(:simple_search) { described_class.new(options) }

  def search_with(regex)
    described_class.new(ActiveSupport::HashWithIndifferentAccess.new({ 'value' => 'x', 'regex' => regex }))
  end

  describe 'option methods' do
    it 'regexp?' do
      expect(simple_search.regexp?).to be(true)
    end

    it 'value' do
      expect(simple_search.value).to eq('search value')
    end
  end

  # A form-encoded body reaches Rails as strings ('true'/'false'), while a JSON
  # body preserves booleans. Both encodings must be understood, otherwise a JSON
  # client asking for a regex search is silently given a plain one.
  describe '#regexp? whatever type the param arrives as' do
    it 'is true for the string "true"' do
      expect(search_with('true').regexp?).to be(true)
    end

    it 'is true for the boolean true' do
      expect(search_with(true).regexp?).to be(true)
    end

    it 'is false for the string "false"' do
      expect(search_with('false').regexp?).to be(false)
    end

    it 'is false for the boolean false' do
      expect(search_with(false).regexp?).to be(false)
    end

    it 'is false when the param is missing' do
      expect(search_with(nil).regexp?).to be(false)
    end
  end
end
