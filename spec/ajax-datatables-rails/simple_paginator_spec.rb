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
      expect(records).to receive(:offset)
      datatable.send(:paginate_records, records)
    end

    it 'calls #limit on passed record collection' do
      arry = double('Array', :limit => [])
      allow(records).to receive(:offset).and_return(arry)
      expect(arry).to receive(:limit)
      datatable.send(:paginate_records, records) 
    end
  end
end