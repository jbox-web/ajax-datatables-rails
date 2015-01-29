require 'spec_helper'

class KaminariDatatable < AjaxDatatablesRails::Base
end

describe KaminariDatatable do
  before(:each) do
    allow_any_instance_of(AjaxDatatablesRails::Configuration).to receive(:paginator) { :kaminari }
  end

  describe '#paginate_records' do
    let(:users_database) do
      double('User',
        :all => double('RecordCollection',
          :page => double('Array', :per => [])
        )
      )
    end

    let(:datatable) { KaminariDatatable.new(double('view', :params => {})) }
    let(:records) { users_database.all }

    it 'calls #page on passed record collection' do
      expect(records).to receive(:page)
      datatable.send(:paginate_records, records)
    end

    it 'calls #per_page on passed record collection' do
      arry = double('Array', :per => [])
      allow(records).to receive(:page).and_return(arry)
      expect(arry).to receive(:per)
      datatable.send(:paginate_records, records) 
    end
  end
end
