require 'spec_helper'

describe AjaxDatatablesRails::Datatable::SimpleOrder do

  let(:datatable) { ComplexDatatable.new(sample_params).datatable }
  let(:options) { ActiveSupport::HashWithIndifferentAccess.new({'column' => '1', 'dir' => 'desc'}) }
  let(:simple_order) { AjaxDatatablesRails::Datatable::SimpleOrder.new(datatable, options) }

  describe 'option methods' do
    it 'sql query' do
      expect(simple_order.query('firstname')).to eq('firstname DESC')
    end
  end

  describe 'option methods with nulls last' do
    describe 'using global option' do
      before { AjaxDatatablesRails.config.nulls_last = true }
      after  { AjaxDatatablesRails.config.nulls_last = false }

      it 'sql query' do
        skip('unsupported database adapter') if ENV['DB_ADAPTER'] == 'oracle_enhanced'

        expect(simple_order.query('email')).to eq(
          "email DESC #{nulls_last_sql}"
        )
      end
    end

    describe 'using column option' do
      let(:sorted_datatable) { DatatableOrderNullsLast.new(sample_params).datatable }
      let(:nulls_last_order) { AjaxDatatablesRails::Datatable::SimpleOrder.new(sorted_datatable, options) }

      context 'with postgres database adapter' do
        before { AjaxDatatablesRails.config.db_adapter = :pg }

        it 'sql query' do
          expect(nulls_last_order.query('email')).to eq('email DESC NULLS LAST')
        end
      end

      context 'with sqlite database adapter' do
        before { AjaxDatatablesRails.config.db_adapter = :sqlite }

        it 'sql query' do
          expect(nulls_last_order.query('email')).to eq('email DESC IS NULL')
        end
      end

      context 'with mysql database adapter' do
        before { AjaxDatatablesRails.config.db_adapter = :mysql }

        it 'sql query' do
          expect(nulls_last_order.query('email')).to eq('email DESC IS NULL')
        end
      end
    end
  end
end
