# frozen_string_literal: true

module AjaxDatatablesRails
  module Datatable
    class SimpleOrder

      DIRECTION_ASC  = 'ASC'
      DIRECTION_DESC = 'DESC'
      DIRECTIONS     = [DIRECTION_ASC, DIRECTION_DESC].freeze

      def initialize(datatable, options = {})
        @datatable  = datatable
        @options    = options
        @adapter    = datatable.db_adapter
        @nulls_last = datatable.nulls_last
      end

      def query(sort_column)
        [sort_column, direction, nulls_last_sql].compact.join(' ')
      end

      def column
        @datatable.column_by(:index, column_index)
      end

      def direction
        DIRECTIONS.find { |dir| dir == column_direction } || DIRECTION_ASC
      end

      private

      def column_index
        @options[:column]
      end

      def column_direction
        @options[:dir].upcase
      end

      def sort_nulls_last?
        column.nulls_last? || @nulls_last == true
      end

      PG_NULL_STYLE    = 'NULLS LAST'
      MYSQL_NULL_STYLE = 'IS NULL'
      private_constant :PG_NULL_STYLE
      private_constant :MYSQL_NULL_STYLE

      NULL_STYLE_MAP = {
        pg:         PG_NULL_STYLE,
        postgresql: PG_NULL_STYLE,
        postgres:   PG_NULL_STYLE,
        postgis:    PG_NULL_STYLE,
        oracle:     PG_NULL_STYLE,
        mysql:      MYSQL_NULL_STYLE,
        mysql2:     MYSQL_NULL_STYLE,
        trilogy:    MYSQL_NULL_STYLE,
        sqlite:     MYSQL_NULL_STYLE,
        sqlite3:    MYSQL_NULL_STYLE,
      }.freeze
      private_constant :NULL_STYLE_MAP

      def nulls_last_sql
        return unless sort_nulls_last?

        NULL_STYLE_MAP[@adapter] || raise("unsupported database adapter: #{@adapter}")
      end

    end
  end
end
