require 'spec_helper'

describe AjaxDatatablesRails::Base do

  let(:view) { double('view', params: sample_params) }
  let(:datatable) { ReallyComplexDatatable.new(view) }

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

  describe 'it can filter range records' do
    before(:each) do
      create(:user, username: 'johndoe', email: 'johndoe@example.com', last_name: 'Doe', created_at: '01/01/2000')
      create(:user, username: 'msmith', email: 'mary.smith@example.com', last_name: 'Smith', created_at: '01/02/2000')
    end

    context 'when no range is passed' do
      it 'should not filter records' do
        datatable.params[:columns]['4'][:search][:value] = '-'
        expect(datatable.data.size).to eq 2
        item = datatable.data.first
        expect(item[:last_name]).to eq 'Doe'
      end
    end

    context 'when start_date is passed' do
      it 'should filter records created after this date' do
        datatable.params[:columns]['4'][:search][:value] = '31/12/1999-'
        expect(datatable.data.size).to eq 2
      end
    end

    context 'when end_date is passed' do
      it 'should filter records created before this date' do
        datatable.params[:columns]['4'][:search][:value] = '-31/12/1999'
        expect(datatable.data.size).to eq 0
      end
    end

    context 'when both date are passed' do
      it 'should filter records created between the range' do
        datatable.params[:columns]['4'][:search][:value] = '01/12/1999-15/01/2000'
        expect(datatable.data.size).to eq 1
      end
    end
  end

end
