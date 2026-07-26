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

      # Compared as a string: a form-encoded body carries 'true', a JSON body the
      # boolean true. Without the cast, a JSON client asking for a regex search
      # would silently be given a plain one.
      def regexp?
        @options[:regex].to_s == TRUE_VALUE
      end

    end
  end
end
