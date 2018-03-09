# frozen_string_literal: true

module AjaxDatatablesRails
  module Datatable
    class Column
      module Search

        SMALLEST_PQ_INTEGER = -2147483648
        LARGEST_PQ_INTEGER = 2147483647

        def searchable?
          @view_column.fetch(:searchable, true)
        end

        def cond
          @view_column[:cond] || :like
        end

        def filter
          @view_column[:cond].call(self, formated_value)
        end

        def search
          @search ||= SimpleSearch.new(options[:search])
        end

        def searched?
          search.value.present?
        end

        def search_query
          search.regexp? ? regex_search : non_regex_search
        end

        # Add use_regex option to allow bypassing of regex search
        def use_regex?
          @view_column.fetch(:use_regex, true)
        end

        private

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

        def empty_search
          casted_column.matches("")
        end

        def non_regex_search
          case cond
          when Proc
            filter
          when :eq, :not_eq, :lt, :gt, :lteq, :gteq, :in
            if is_searchable_integer?
              empty_search
            else
              numeric_search
            end
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

        def is_searchable_integer?
          return false unless table.respond_to?(:engine)
          table.engine.columns_hash[field.to_s].sql_type == 'integer' && is_integer?(search.value) && is_out_of_range?(search.value)
        end

        def is_out_of_range? search_value
          Integer(search_value) > LARGEST_PQ_INTEGER || Integer(search_value) < SMALLEST_PQ_INTEGER
        end

        def is_integer?(string)
          true if Integer(string) rescue false
        end
      end
    end
  end
end
