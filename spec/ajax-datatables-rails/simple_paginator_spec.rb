require 'spec_helper'

class SimplePaginateDatatable < AjaxDatatablesRails::Base
  include AjaxDatatablesRails::Extensions::SimplePaginator
end

describe SimplePaginateDatatable do
  describe '#paginate_records' do
    let(:users_database) do
      double('User',
        :all => double('RecordCollection',
          :offset => double('Array', :limit => [])
        )
      )
    end

    let(:datatable) { SimplePaginateDatatable.new(double('view', :params => {})) }
    let(:records) { users_database.all }

    it 'calls #offset on passed record collection' do
      records.should_receive(:offset)
      datatable.send(:paginate_records, records)
    end

    it 'calls #limit on passed record collection' do
      arry = double('Array', :limit => [])
      records.stub(:offset).and_return(arry)
      arry.should_receive(:limit)
      datatable.send(:paginate_records, records) 
    end
  end
end