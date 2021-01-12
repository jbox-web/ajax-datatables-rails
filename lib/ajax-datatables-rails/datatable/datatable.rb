# frozen_string_literal: true

module AjaxDatatablesRails
  module Datatable
    class Datatable
      attr_reader :options

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
          Column.new(@datatable, index, column_options)
        end
      end

      def column_by(how, what)
        columns.find { |simple_column| simple_column.send(how) == what }
      end

      # ----------------- OPTIONS METHODS --------------------

      def paginate?
        per_page != -1
      end

      def per_page
        options.fetch(:length, 10).to_i
      end

      def offset
        options.fetch(:start, 0).to_i
      end

      def page
        (offset / per_page) + 1
      end

      def get_param(param)
        return {} if options[param].nil?

        if options[param].is_a? Array
          hash = {}
          options[param].each_with_index { |value, index| hash[index] = value }
          hash
        else
          options[param].to_unsafe_h.with_indifferent_access
        end
      end

      def db_adapter
        @datatable.db_adapter
      end

      def nulls_last
        @datatable.nulls_last
      end

    end
  end
end
