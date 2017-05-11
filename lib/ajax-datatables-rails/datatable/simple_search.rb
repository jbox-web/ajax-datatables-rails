module AjaxDatatablesRails
  module Datatable
    class SimpleSearch

      def initialize(options = {})
        @options = options
      end

      def value
        @options[:value]
      end

      def regexp?
        @options[:regex] == TRUE_VALUE
      end
    end
  end
end
