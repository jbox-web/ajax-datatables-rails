require 'spec_helper'

class WillPaginateDatatable < AjaxDatatablesRails::Base
  include AjaxDatatablesRails::Extensions::WillPaginate
end

describe WillPaginateDatatable do
  describe '#paginate_records' do
    let(:users_database) do
      double('User',
        :all => double('RecordCollection',
          :paginate => double('Array', :per_page => [])
        )
      )
    end

    let(:datatable) { WillPaginateDatatable.new(double('view', :params => {})) }
    let(:records) { users_database.all }

    it 'calls #page and #per_page on passed record collection' do
      records.should_receive(:paginate).with(:page=>1, :per_page=>10)
      datatable.send(:paginate_records, records)
    end
  end
end