module AjaxDatatablesRails
  module Datatable
    class Column
      attr_reader :index, :options

      def initialize(index, options = {})
        @index, @options = index, options
      end

      def data
        options[:data] || options[:name]
      end

      def searchable?
        options[:searchable] == 'true'
      end

      def orderable?
        options[:orderable] == 'true'
      end

      def search
        @search ||= SimpleSearch.new(options[:search])
      end
    end
  end
end