# frozen_string_literal: true

module AjaxDatatablesRails
  module Datatable
    class SimpleSearch

      TRUE_VALUE = 'true'

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
