# frozen_string_literal: true

module AjaxDatatablesRails
  module Datatable
    class Column

      TYPE_CAST_DEFAULT = 'VARCHAR'
      TYPE_CAST_MYSQL   = 'CHAR'
      TYPE_CAST_SQLITE  = 'TEXT'
      TYPE_CAST_ORACLE  = 'VARCHAR2(4000)'

      DB_ADAPTER_TYPE_CAST = {
        mysql:          TYPE_CAST_MYSQL,
        mysql2:         TYPE_CAST_MYSQL,
        sqlite:         TYPE_CAST_SQLITE,
        sqlite3:        TYPE_CAST_SQLITE,
        oracle:         TYPE_CAST_ORACLE,
        oracleenhanced: TYPE_CAST_ORACLE
      }.freeze

      attr_reader :datatable, :index, :options
      attr_writer :search

      include Search
      include Order
      include DateFilter


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
        @type_cast ||= DB_ADAPTER_TYPE_CAST.fetch(AjaxDatatablesRails.config.db_adapter, TYPE_CAST_DEFAULT)
      end

      def casted_column
        @casted_column ||= ::Arel::Nodes::NamedFunction.new('CAST', [table[field].as(type_cast)])
      end

    end
  end
end
