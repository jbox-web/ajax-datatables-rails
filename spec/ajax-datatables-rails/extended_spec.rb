require 'spec_helper'

describe AjaxDatatablesRails::Base do

  let(:view) { double('view', params: sample_params) }
  let(:datatable) { ComplexDatatableHash.new(view) }

  describe 'it can transform search value before asking the database' do
    before(:each) do
      create(:user, username: 'johndoe', email: 'johndoe@example.com', last_name: 'Doe')
      create(:user, username: 'msmith', email: 'mary.smith@example.com', last_name: 'Smith')
      datatable.params[:columns]['3'][:search][:value] = 'DOE'
    end

    it 'should filter records' do
      expect(datatable.data.size).to eq 1
      item = datatable.data.first
      expect(item[:last_name]).to eq 'Doe'
    end
  end

end
