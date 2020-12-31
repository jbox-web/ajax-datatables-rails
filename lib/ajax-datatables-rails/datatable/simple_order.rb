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

      def nulls_last_sql
        return unless sort_nulls_last?

        case @adapter
        when :pg, :postgresql, :postgres, :oracle
          'NULLS LAST'
        when :mysql, :mysql2, :sqlite, :sqlite3
          'IS NULL'
        else
          raise "unsupported database adapter: #{@adapter}"
        end
      end

    end
  end
end
