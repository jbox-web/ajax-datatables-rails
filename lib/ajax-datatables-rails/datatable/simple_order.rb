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
        return "#{sort_column} #{direction}" unless sort_nulls_last?

        nulls_last_query(sort_column)
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

      # A malformed order param may omit `dir`; `to_s` keeps this nil-safe and
      # `direction` then falls back to ASC via its `|| DIRECTION_ASC`.
      def column_direction
        @options[:dir].to_s.upcase
      end

      def sort_nulls_last?
        column.nulls_last? || @nulls_last == true
      end

      # NULLs-last ordering has no portable syntax. PostgreSQL and Oracle support
      # the native, index-friendly `NULLS LAST` suffix. MySQL and SQLite do not,
      # so a leading `<col> IS NULL` key (0 for present values, 1 for NULLs) sorts
      # them last — and it MUST be a separate, comma-separated ordering term:
      # appending `IS NULL` after `<col> <dir>` is a SQL syntax error.
      def nulls_last_query(sort_column)
        case null_sort_style
        when :native
          "#{sort_column} #{direction} NULLS LAST"
        when :is_null
          "#{sort_column} IS NULL, #{sort_column} #{direction}"
        end
      end

      NULL_SORT_STYLE = {
        pg:         :native,
        postgresql: :native,
        postgres:   :native,
        postgis:    :native,
        oracle:     :native,
        mysql:      :is_null,
        mysql2:     :is_null,
        trilogy:    :is_null,
        sqlite:     :is_null,
        sqlite3:    :is_null,
      }.freeze
      private_constant :NULL_SORT_STYLE

      def null_sort_style
        NULL_SORT_STYLE[@adapter] || raise("unsupported database adapter: #{@adapter}")
      end

    end
  end
end
