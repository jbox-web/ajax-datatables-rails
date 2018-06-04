# frozen_string_literal: true

module AjaxDatatablesRails
  module Datatable
    class SimpleOrder

      DIRECTION_ASC  = 'ASC'
      DIRECTION_DESC = 'DESC'
      DIRECTIONS     = [DIRECTION_ASC, DIRECTION_DESC].freeze

      def initialize(datatable, options = {})
        @datatable = datatable
        @options   = options
      end

      def query(sort_column)
        if sort_nulls_last?
          "CASE WHEN #{sort_column} IS NULL THEN 1 ELSE 0 END, #{sort_column} #{direction}"
        else
          "#{sort_column} #{direction}"
        end
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
        column.nulls_last? || AjaxDatatablesRails.config.nulls_last == true
      end

    end
  end
end
