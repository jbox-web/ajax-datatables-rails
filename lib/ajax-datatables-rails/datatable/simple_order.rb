module AjaxDatatablesRails
  module Datatable
    class SimpleOrder

      DIRECTIONS = %w[DESC ASC].freeze

      def initialize(datatable, options = {})
        @datatable = datatable
        @options   = options
      end

      def query(sort_column)
        "#{sort_nulls_last(sort_column)}#{sort_column} #{direction}"
      end

      def column
        @datatable.column_by(:index, column_index)
      end

      def direction
        DIRECTIONS.find { |dir| dir == @options[:dir].upcase } || 'ASC'
      end
      
      def sort_nulls_last(sort_column)
        if column.nulls_last == true || AjaxDatatablesRails.config.nulls_last == true
          "CASE WHEN #{sort_column} IS NULL THEN 1 ELSE 0 END, "
        else
          return nil
        end
      end

      private

      def column_index
        @options[:column]
      end
    end
  end
end
