# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AjaxDatatablesRails::Datatable::SimpleOrder do

  let(:parent) { ComplexDatatable.new(sample_params) }
  let(:datatable) { parent.datatable }
  let(:options) { ActiveSupport::HashWithIndifferentAccess.new({ 'column' => '1', 'dir' => 'desc' }) }
  let(:simple_order) { AjaxDatatablesRails::Datatable::SimpleOrder.new(datatable, options) }

  describe 'option methods' do
    it 'sql query' do
      expect(simple_order.query('firstname')).to eq('firstname DESC')
    end
  end

  describe 'option methods with nulls last' do
    describe 'using class option' do
      before { parent.nulls_last = true }
      after  { parent.nulls_last = false }

      it 'sql query' do
        skip('unsupported database adapter') if ENV['DB_ADAPTER'] == 'oracle_enhanced'

        expect(simple_order.query('email')).to eq(
          "email DESC #{nulls_last_sql(parent)}"
        )
      end
    end

    describe 'using column option' do
      let(:parent) { DatatableOrderNullsLast.new(sample_params) }
      let(:sorted_datatable) { parent.datatable }
      let(:nulls_last_order) { AjaxDatatablesRails::Datatable::SimpleOrder.new(sorted_datatable, options) }

      context 'with postgres database adapter' do
        before { parent.db_adapter = :pg }

        it 'sql query' do
          expect(nulls_last_order.query('email')).to eq('email DESC NULLS LAST')
        end
      end

      context 'with sqlite database adapter' do
        before { parent.db_adapter = :sqlite }

        it 'sql query' do
          expect(nulls_last_order.query('email')).to eq('email DESC IS NULL')
        end
      end

      context 'with mysql database adapter' do
        before { parent.db_adapter = :mysql }

        it 'sql query' do
          expect(nulls_last_order.query('email')).to eq('email DESC IS NULL')
        end
      end
    end
  end
end
