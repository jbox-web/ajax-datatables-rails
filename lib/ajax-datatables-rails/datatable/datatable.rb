module AjaxDatatablesRails
  module Datatable

    TRUE_VALUE = 'true'.freeze

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
        return @orders if @orders
        @orders = []
        options[:order].each do |_, order_options|
          @orders << SimpleOrder.new(self, order_options)
        end
        @orders
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
        return @columns if @columns
        @columns = []
        options[:columns].each do |index, column_options|
          @columns << Column.new(datatable, index, column_options)
        end
        @columns
      end

      def column_by(how, what)
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
