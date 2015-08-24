module AjaxDatatablesRails
  module Datatable
    class Column
      attr_reader :index, :options

      def initialize(index, options = {}, view_column = {})
        @index, @options = index, options
        @view_column = view_column || {}
      end

      def data
        options[:data] || options[:name]
      end

      def searchable?
        options[:searchable] == 'true'
      end

      def orderable?
        options[:orderable] == 'true'
      end

      def search
        @search ||= SimpleSearch.new(options[:search])
      end

      def cond
        @view_column[:cond] || :like
      end

      def source
        @view_column[:source]
      end

      def table
        model = source.split('.').first.constantize
        model.arel_table rescue table_from_downcased(model)
      end

      def field
        source.split('.').last.to_sym
      end

      def search_query
        search.regexp? ? regex_search : non_regex_search
      end

      def sort_query
        "#{ table.name }.#{ field }"
      end

      private
      def config
        @config ||= AjaxDatatablesRails.config
      end

      def regex_search
        ::Arel::Nodes::Regexp.new(table[field], ::Arel::Nodes.build_quoted(search.value))
      end

      def non_regex_search
        casted_column = ::Arel::Nodes::NamedFunction.new(
          'CAST', [table[field].as(typecast)]
        )
        case cond
        when :lteq, :gteq, :eq
          table[field].send(cond, search.value)
        else
          casted_column.matches("%#{ search.value }%")
        end
      end

      def typecast
        case config.db_adapter
        when :mysql, :mysql2 then 'CHAR'
        when :sqlite, :sqlite3 then 'TEXT'
        else
          'VARCHAR'
        end
      end

      def table_from_downcased(model)
        model.singularize.titleize.gsub( / /, '' ).constantize.arel_table
      rescue
        ::Arel::Table.new(model.to_sym, ::ActiveRecord::Base)
      end

    end
  end
end