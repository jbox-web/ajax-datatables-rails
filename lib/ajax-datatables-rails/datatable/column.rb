# frozen_string_literal: true

module AjaxDatatablesRails
  module Datatable
    class Column

      DB_ADAPTER_TYPE_CAST = {
        mysql:          'CHAR',
        mysql2:         'CHAR',
        sqlite:         'TEXT',
        sqlite3:        'TEXT',
        oracle:         'VARCHAR2(4000)',
        oracleenhanced: 'VARCHAR2(4000)'
      }.freeze

      attr_reader :datatable, :index, :options
      attr_writer :search

      include Search
      include Order
      prepend DateFilter


      def initialize(datatable, index, options)
        @datatable   = datatable
        @index       = index
        @options     = options
        @view_column = datatable.view_columns[options[:data].to_sym]
      end

      def data
        options[:data].presence || options[:name]
      end

      def source
        @view_column[:source]
      end

      def table
        model.respond_to?(:arel_table) ? model.arel_table : model
      end

      def model
        @model ||= source.split('.').first.constantize
      end

      def field
        @field ||= source.split('.').last.to_sym
      end

      def custom_field?
        !source.include?('.')
      end

      # Add formatter option to allow modification of the value
      # before passing it to the database
      def formatter
        @view_column[:formatter]
      end

      def formatted_value
        formatter ? formatter.call(search.value) : search.value
      end

      private

      def type_cast
        @type_cast ||= (DB_ADAPTER_TYPE_CAST[AjaxDatatablesRails.config.db_adapter] || 'VARCHAR')
      end

      def casted_column
        @casted_column ||= ::Arel::Nodes::NamedFunction.new('CAST', [table[field].as(type_cast)])
      end

    end
  end
end
