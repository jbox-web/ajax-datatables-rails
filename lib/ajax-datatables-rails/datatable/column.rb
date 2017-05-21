require 'ostruct'

module AjaxDatatablesRails
  module Datatable
    class Column
      attr_reader :datatable, :index, :options

      unless AjaxDatatablesRails.old_rails?
        prepend ColumnDateFilter
      end

      def initialize(datatable, index, options)
        @datatable, @index, @options = datatable, index, options
        @view_column = datatable.view_columns[options["data"].to_sym]
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

      def search=(value)
        @search = value
      end

      def cond
        @view_column[:cond] || :like
      end

      def filter(value)
        @view_column[:cond].call(value)
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

      # Add delimiter option to handle range search
      def delimiter
        @view_column[:delimiter] || '-'
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

      private

      def custom_field?
        !source.include?('.')
      end

      def config
        @config ||= AjaxDatatablesRails.config
      end

      def formated_value
        formater ? formater.call(search.value) : search.value
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
          filter(formated_value)
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
        else
          nil
        end
      end

      def typecast
        case config.db_adapter
        when :oracle, :oracleenhanced then 'VARCHAR2(4000)'
        when :mysql, :mysql2   then 'CHAR'
        when :sqlite, :sqlite3 then 'TEXT'
        else
          'VARCHAR'
        end
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
