module AjaxDatatablesRails
  module Datatable
    class SimpleOrder
      attr_reader :datatable, :options

      DIRECTIONS = %w(DESC ASC)

      def initialize(datatable, options)
        @datatable = datatable
        @options = options || {}
      end

      def query sort_column
        "#{ sort_column } #{ dir }"
      end

      def column
        datatable.column_by(:index, column_index)
      end

      private
      def dir
        DIRECTIONS.find { |direction| direction == options[:dir].upcase } || 'ASC'
      end

      def column_index
        options[:column]
      end
    end
  end
end
