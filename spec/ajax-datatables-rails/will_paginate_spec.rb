require 'spec_helper'

class WillPaginateDatatable < AjaxDatatablesRails::Base
end

describe WillPaginateDatatable do
  before(:each) do
    allow_any_instance_of(AjaxDatatablesRails::Configuration).to receive(:paginator) { :will_paginate }
  end

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
      expect(records).to receive(:paginate).with(:page=>1, :per_page=>10)
      datatable.send(:paginate_records, records)
    end
  end
end
