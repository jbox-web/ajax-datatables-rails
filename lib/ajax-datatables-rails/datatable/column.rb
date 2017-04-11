module AjaxDatatablesRails
  module Datatable
    class Column
      attr_reader :datatable, :index, :options

      def initialize(datatable, index, options)
        @datatable, @index, @options = datatable, index, options
        @view_column = datatable.view_columns[options["data"].to_sym]
      end

      def data
        options[:data].presence || options[:name]
      end

      def searchable?
        options[:searchable] == TRUE_VALUE
      end

      def orderable?
        options[:orderable] == TRUE_VALUE
      end

      def search
        @search ||= SimpleSearch.new(options[:search])
      end

      def search=(value)
        @search = value
      end

      def cond
        @view_column[:cond] || :like
      end

      def filter(value)
        @view_column[:cond].call self
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
        if custom_field?
          source
        else
          "#{table.name}.#{sort_field}"
        end
      end

      private

      def custom_field?
        !source.include?('.')
      end

      def config
        @config ||= AjaxDatatablesRails.config
      end

      def formated_value
        if formater
          formater.call(search.value)
        else
          search.value
        end
      end

      # Using multi-select filters in JQuery Datatable auto-enables regex_search.
      # Unfortunately regex_search doesn't work when filtering on primary keys with integer.
      # It generates this kind of query : AND ("regions"."id" ~ '2|3') which throws an error :
      # operator doesn't exist : integer ~ unknown
      # The solution is to bypass regex_search and use non_regex_search with :in operator
      def regex_search
        if use_regex?
          value = formated_value
          ::Arel::Nodes::Regexp.new((custom_field? ? field : table[field]), ::Arel::Nodes.build_quoted(value))
        else
          non_regex_search
        end
      end

      def non_regex_search
        case cond
        when Proc
          filter search.value
        when :eq, :not_eq, :lt, :gt, :lteq, :gteq, :in
          if custom_field?
            ::Arel::Nodes::SqlLiteral.new(field).eq(search.value)
          else
            table[field].send(cond, search.value)
          end
        else
          casted_column = ::Arel::Nodes::NamedFunction.new(
            'CAST', [table[field].as(typecast)]
          )
          casted_column.matches("%#{ search.value }%")
        end
      end

      def typecast
        case config.db_adapter
        when :mysql, :mysql2   then 'CHAR'
        when :sqlite, :sqlite3 then 'TEXT'
        else
          'VARCHAR'
        end
      end

    end
  end
end
