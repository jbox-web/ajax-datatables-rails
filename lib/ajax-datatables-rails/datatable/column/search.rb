# frozen_string_literal: true

module AjaxDatatablesRails
  module Datatable
    class Column
      module Search

        SMALLEST_PQ_INTEGER = -2_147_483_648
        LARGEST_PQ_INTEGER  = 2_147_483_647
        NOT_NULL_VALUE      = '!NULL'
        EMPTY_VALUE         = ''

        def searchable?
          @view_column.fetch(:searchable, true)
        end

        def cond
          @view_column.fetch(:cond, :like)
        end

        def filter
          @view_column[:cond].call(self, formatted_value)
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
            ::Arel::Nodes::Regexp.new((custom_field? ? field : table[field]), ::Arel::Nodes.build_quoted(formatted_value))
          else
            non_regex_search
          end
        end

        # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity
        def non_regex_search
          case cond
          when Proc
            filter
          when :eq, :not_eq, :lt, :gt, :lteq, :gteq, :in
            searchable_integer? ? raw_search(cond) : empty_search
          when :start_with
            text_search("#{formatted_value}%")
          when :end_with
            text_search("%#{formatted_value}")
          when :like
            text_search("%#{formatted_value}%")
          when :string_eq
            raw_search(:eq)
          when :string_in
            raw_search(:in)
          when :null_value
            null_value_search
          when :date_range
            date_range_search
          end
        end
        # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity

        def null_value_search
          if formatted_value == NOT_NULL_VALUE
            table[field].not_eq(nil)
          else
            table[field].eq(nil)
          end
        end

        def raw_search(cond)
          if custom_field?
            ::Arel::Nodes::SqlLiteral.new(field).eq(formatted_value)
          else
            table[field].send(cond, formatted_value)
          end
        end

        def text_search(value)
          casted_column.matches(value)
        end

        def empty_search
          casted_column.matches(EMPTY_VALUE)
        end

        def searchable_integer?
          if formatted_value.is_a?(Array)
            valids = formatted_value.map { |v| integer?(v) && !out_of_range?(v) }
            !valids.include?(false)
          else
            integer?(formatted_value) && !out_of_range?(formatted_value)
          end
        end

        def out_of_range?(search_value)
          Integer(search_value) > LARGEST_PQ_INTEGER || Integer(search_value) < SMALLEST_PQ_INTEGER
        end

        def integer?(string)
          Integer(string)
          true
        rescue ArgumentError
          false
        end

      end
    end
  end
end
