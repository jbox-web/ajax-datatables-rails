require 'spec_helper'

class KaminariDatatable < AjaxDatatablesRails::Base
  include AjaxDatatablesRails::Extensions::Kaminari
end

describe KaminariDatatable do
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
      records.should_receive(:page)
      datatable.send(:paginate_records, records)
    end

    it 'calls #per_page on passed record collection' do
      arry = double('Array', :per => [])
      records.stub(:page).and_return(arry)
      arry.should_receive(:per)
      datatable.send(:paginate_records, records) 
    end
  end
end