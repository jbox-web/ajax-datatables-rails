# frozen_string_literal: true

module AjaxDatatablesRails
  module Datatable
    class Column

      DB_ADAPTER_TYPE_CAST = {
        mysql:          'CHAR',
        mysql2:         'CHAR',
        sqlite:         'TEXT',
        sqlite3:        'TEXT',
        oracle:         'VARCHAR2(4000)',
        oracleenhanced: 'VARCHAR2(4000)',
      }.freeze

      attr_reader :datatable, :index, :options
      attr_writer :search

      unless AjaxDatatablesRails.old_rails?
        prepend DateFilter
      end

      def initialize(datatable, index, options)
        @datatable   = datatable
        @index       = index
        @options     = options
        @view_column = datatable.view_columns[options['data'].to_sym]
      end

      def data
        options[:data].presence || options[:name]
      end

      def searchable?
        @view_column.fetch(:searchable, true)
      end

      def orderable?
        @view_column.fetch(:orderable, true)
      end

      def search
        @search ||= SimpleSearch.new(options[:search])
      end

      def searched?
        search.value.present?
      end

      def cond
        @view_column[:cond] || :like
      end

      def filter
        @view_column[:cond].call(self, formated_value)
      end

      def source
        @view_column[:source]
      end

      # Add sort_field option to allow overriding of sort field
      def sort_field
        @view_column[:sort_field] || field
      end

      # Add formater option to allow modification of the value
      # before passing it to the database
      def formater
        @view_column[:formater]
      end

      # Add use_regex option to allow bypassing of regex search
      def use_regex?
        @view_column.fetch(:use_regex, true)
      end

      def table
        model = source.split('.').first.constantize
        model.arel_table rescue model
      end

      def field
        source.split('.').last.to_sym
      end

      def search_query
        search.regexp? ? regex_search : non_regex_search
      end

      def sort_query
        custom_field? ? source : "#{table.name}.#{sort_field}"
      end

      def formated_value
        formater ? formater.call(search.value) : search.value
      end

      private

      def custom_field?
        !source.include?('.')
      end

      def config
        @config ||= AjaxDatatablesRails.config
      end

      # Using multi-select filters in JQuery Datatable auto-enables regex_search.
      # Unfortunately regex_search doesn't work when filtering on primary keys with integer.
      # It generates this kind of query : AND ("regions"."id" ~ '2|3') which throws an error :
      # operator doesn't exist : integer ~ unknown
      # The solution is to bypass regex_search and use non_regex_search with :in operator
      def regex_search
        if use_regex?
          ::Arel::Nodes::Regexp.new((custom_field? ? field : table[field]), ::Arel::Nodes.build_quoted(formated_value))
        else
          non_regex_search
        end
      end

      def non_regex_search
        case cond
        when Proc
          filter
        when :eq, :not_eq, :lt, :gt, :lteq, :gteq, :in
          numeric_search
        when :null_value
          null_value_search
        when :start_with
          casted_column.matches("#{formated_value}%")
        when :end_with
          casted_column.matches("%#{formated_value}")
        when :like
          casted_column.matches("%#{formated_value}%")
        end
      end

      def typecast
        DB_ADAPTER_TYPE_CAST[config.db_adapter] || 'VARCHAR'
      end

      def casted_column
        ::Arel::Nodes::NamedFunction.new('CAST', [table[field].as(typecast)])
      end

      def null_value_search
        if formated_value == '!NULL'
          table[field].not_eq(nil)
        else
          table[field].eq(nil)
        end
      end

      def numeric_search
        if custom_field?
          ::Arel::Nodes::SqlLiteral.new(field).eq(formated_value)
        else
          table[field].send(cond, formated_value)
        end
      end

    end
  end
end
