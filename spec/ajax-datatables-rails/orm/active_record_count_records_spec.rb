# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AjaxDatatablesRails::ORM::ActiveRecord do

  let(:datatable) { ComplexDatatable.new(sample_params) }
  let(:records) { User.all }

  describe '#records_total_count' do
    context 'ungrouped results' do
      it 'returns the count' do
        expect(datatable.send(:records_total_count)).to eq records.count
      end
    end

    context 'grouped results' do
      let(:datatable) { GroupedDatatable.new(sample_params) }

      it 'returns the count' do
        expect(datatable.send(:records_total_count)).to eq records.count
      end
    end
  end


  describe '#records_filtered_count' do
    context 'ungrouped results' do
      it 'returns the count' do
        expect(datatable.send(:records_filtered_count)).to eq records.count
      end
    end

    context 'grouped results' do
      let(:datatable) { GroupedDatatable.new(sample_params) }

      it 'returns the count' do
        expect(datatable.send(:records_filtered_count)).to eq records.count
      end
    end
  end
end
