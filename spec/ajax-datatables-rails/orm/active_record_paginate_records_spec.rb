require 'spec_helper'

describe AjaxDatatablesRails::ORM::ActiveRecord do

  let(:datatable) { ComplexDatatable.new(sample_params) }
  let(:records) { User.all }

  before(:each) do
    create(:user, username: 'johndoe', email: 'johndoe@example.com')
    create(:user, username: 'msmith', email: 'mary.smith@example.com')
  end

  describe '#paginate_records' do
    it 'requires a records collection argument' do
      expect { datatable.paginate_records }.to raise_error(ArgumentError)
    end

    it 'paginates records properly' do
      if AjaxDatatablesRails.config.db_adapter.in? %i[oracle oracleenhanced]
        if Rails.version.in? %w[4.0.13 4.1.16 4.2.10]
          expect(datatable.paginate_records(records).to_sql).to include(
            'rownum <= 10'
          )
        else
          expect(datatable.paginate_records(records).to_sql).to include(
            'rownum <= (0 + 10)'
          )
        end
      else
        expect(datatable.paginate_records(records).to_sql).to include(
          'LIMIT 10 OFFSET 0'
        )
      end

      datatable.params[:start] = '26'
      datatable.params[:length] = '25'
      if AjaxDatatablesRails.config.db_adapter.in? %i[oracle oracleenhanced]
        if Rails.version.in? %w[4.0.13 4.1.16 4.2.10]
          expect(datatable.paginate_records(records).to_sql).to include(
            'rownum <= 51'
          )
        else
          expect(datatable.paginate_records(records).to_sql).to include(
            'rownum <= (26 + 25)'
          )
        end
      else
        expect(datatable.paginate_records(records).to_sql).to include(
          'LIMIT 25 OFFSET 26'
        )
      end
    end

    it 'depends on the value of #offset' do
      expect(datatable.datatable).to receive(:offset)
      datatable.paginate_records(records)
    end

    it 'depends on the value of #per_page' do
      expect(datatable.datatable).to receive(:per_page).at_least(:once) { 10 }
      datatable.paginate_records(records)
    end
  end

end
