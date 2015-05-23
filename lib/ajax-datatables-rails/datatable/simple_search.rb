module AjaxDatatablesRails
  module Datatable
    class SimpleSearch
      attr_reader :options

      def initialize(options = {})
        @options = options
      end

      def value
        options[:value]
      end

      def regexp?
        options[:regexp] == 'true'
      end
    end
  end
end