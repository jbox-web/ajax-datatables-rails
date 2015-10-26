module AjaxDatatablesRails
  module Datatable
    class SimpleOrder
      attr_reader :datatable, :options

      DIRECTIONS = %w(desc asc)

      def initialize(datatable, options)
        @datatable = datatable
        @options = options || {}
      end

      def dir
        DIRECTIONS.include?(options[:dir]) ? options[:dir].upcase : 'ASC'
      end

      def query(sort_column)
        "#{ sort_column } #{ dir }"
      end

      def column
        datatable.column(:index, column_index)
      end

      def column_index
        options[:column]
      end
    end
  end
end