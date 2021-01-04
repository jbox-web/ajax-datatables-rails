# frozen_string_literal: true

module AjaxDatatablesRails
  module Datatable
    class Column

      include Search
      include Order
      include DateFilter

      attr_reader :datatable, :index, :options
      attr_writer :search

      def initialize(datatable, index, options)
        @datatable   = datatable
        @index       = index
        @options     = options
        @view_column = datatable.view_columns[column_name]
        validate_settings!
      end

      def column_name
        @column_name ||= options[:data]&.to_sym
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

      TYPE_CAST_DEFAULT   = 'VARCHAR'
      TYPE_CAST_MYSQL     = 'CHAR'
      TYPE_CAST_SQLITE    = 'TEXT'
      TYPE_CAST_ORACLE    = 'VARCHAR2(4000)'
      TYPE_CAST_SQLSERVER = 'VARCHAR(4000)'

      DB_ADAPTER_TYPE_CAST = {
        mysql:          TYPE_CAST_MYSQL,
        mysql2:         TYPE_CAST_MYSQL,
        sqlite:         TYPE_CAST_SQLITE,
        sqlite3:        TYPE_CAST_SQLITE,
        oracle:         TYPE_CAST_ORACLE,
        oracleenhanced: TYPE_CAST_ORACLE,
        sqlserver:      TYPE_CAST_SQLSERVER,
      }.freeze

      private_constant :TYPE_CAST_DEFAULT
      private_constant :TYPE_CAST_MYSQL
      private_constant :TYPE_CAST_SQLITE
      private_constant :TYPE_CAST_ORACLE
      private_constant :TYPE_CAST_SQLSERVER
      private_constant :DB_ADAPTER_TYPE_CAST

      def type_cast
        @type_cast ||= DB_ADAPTER_TYPE_CAST.fetch(datatable.db_adapter, TYPE_CAST_DEFAULT)
      end

      def casted_column
        @casted_column ||= ::Arel::Nodes::NamedFunction.new('CAST', [table[field].as(type_cast)])
      end

      def validate_settings!
        raise AjaxDatatablesRails::Error::InvalidSearchColumn, "Unknown column. Check that `data` field is filled on JS side with the column name" if column_name.empty?
        raise AjaxDatatablesRails::Error::InvalidSearchColumn, "Check that column '#{column_name}' exists in view_columns" unless valid_search_column?(column_name)
        raise AjaxDatatablesRails::Error::InvalidSearchCondition, cond unless valid_search_condition?(cond)
      end

      def valid_search_column?(column_name)
        !datatable.view_columns[column_name].nil?
      end

      VALID_SEARCH_CONDITIONS = [
        # String condition
        :start_with, :end_with, :like, :string_eq, :string_in, :null_value,
        # Numeric condition
        :eq, :not_eq, :lt, :gt, :lteq, :gteq, :in,
        # Date condition
        :date_range
      ].freeze

      private_constant :VALID_SEARCH_CONDITIONS

      def valid_search_condition?(cond)
        return true if cond.is_a?(Proc)

        VALID_SEARCH_CONDITIONS.include?(cond)
      end

    end
  end
end
