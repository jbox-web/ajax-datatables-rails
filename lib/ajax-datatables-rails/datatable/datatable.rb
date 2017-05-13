module AjaxDatatablesRails
  module Datatable

    TRUE_VALUE = 'true'.freeze

    class Datatable
      attr_reader :datatable, :options

      def initialize(datatable)
        @datatable = datatable
        @options   = datatable.params
      end

      # ----------------- ORDER METHODS --------------------

      def orderable?
        options[:order].present?
      end

      def orders
        @orders ||= get_param(:order).map do |_, order_options|
          SimpleOrder.new(self, order_options)
        end
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
        @columns ||= get_param(:columns).map do |index, column_options|
          Column.new(datatable, index, column_options)
        end
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

      def get_param(param)
        if AjaxDatatablesRails.old_rails?
          options[param]
        else
          options[param].to_unsafe_h.with_indifferent_access
        end
      end
    end
  end
end
