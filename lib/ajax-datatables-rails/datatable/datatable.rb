module AjaxDatatablesRails
  module Datatable
    class Datatable
      attr_reader :options

      def initialize(options)
        @options = options
      end

      # ----------------- ORDER METHODS --------------------

      def orderable?
        options[:order].present?
      end

      def orders
        @orders ||= options[:order].map { |index, order_options| SimpleOrder.new(self, index, order_options) }
      end

      def order key, value
        orders.find { |o| o.send(key) == value }
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
        @columns ||= options[:columns].map { |index, col| Column.new(index, col) }
      end

      def column key, value
        columns.find { |col| col.send(key) == value }
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