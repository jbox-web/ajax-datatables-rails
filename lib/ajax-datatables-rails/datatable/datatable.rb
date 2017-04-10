module AjaxDatatablesRails
  module Datatable

    TRUE_VALUE = 'true'

    class Datatable
      attr_reader :datatable, :options

      def initialize datatable
        @datatable = datatable
        @options = datatable.params
      end

      # ----------------- ORDER METHODS --------------------

      def orderable?
        options[:order].present?
      end

      def orders
        @orders ||= options[:order].map { |_, order_options| SimpleOrder.new(self, order_options) }
      end

      def order_by(how, what)
        orders.find { |simple_order| simple_order.send(how) == what }
      end

      # ----------------- SEARCH METHODS --------------------

      def searchable?
        options[:search].present? && options[:search][:value].present?
      end

      def search
        @search ||= SimpleSearch.new(options[:search])
      end

      # ----------------- COLUMN METHODS --------------------

      def columns
        @columns ||= options[:columns].map do |index, column_options|
          Column.new(datatable, index, column_options)
        end
      end

      def column_by how, what
        columns.find { |simple_column| simple_column.send(how) == what }
      end

      # ----------------- OPTIONS METHODS --------------------

      def paginate?
        per_page != -1
      end

      def offset
        (page - 1) * per_page
      end

      def page
        (options[:start].to_i / per_page) + 1
      end

      def per_page
        options.fetch(:length, 10).to_i
      end
    end
  end
end
