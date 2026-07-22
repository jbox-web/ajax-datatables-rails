# frozen_string_literal: true

module AjaxDatatablesRails
  module Datatable
    class Column
      module Search

        # Signed-integer ranges by column byte size. The guard only exists to
        # dodge PostgreSQL's strict "value out of range" error; PG always reports
        # the limit, so nil (e.g. SQLite, which never raises) falls back to bigint.
        INTEGER_RANGE_BY_BYTES = {
          2 => (-32_768..32_767),
          4 => (-2_147_483_648..2_147_483_647),
          8 => (-9_223_372_036_854_775_808..9_223_372_036_854_775_807),
        }.freeze
        DEFAULT_INTEGER_BYTES = 8

        NOT_NULL_VALUE = '!NULL'
        EMPTY_VALUE    = ''

        def searchable?
          @view_column.fetch(:searchable, true) && searchable_field?
        end

        # A dotted source (Model.field) is only searchable if `field` is a real
        # database column; building a WHERE against a source that points at an
        # association name (e.g. `Model.user` when the column is `user_id`) would
        # raise. Custom fields (no dot in the source) never hit the DB directly,
        # so they are always allowed here and filtered out later in the query.
        def searchable_field?
          custom_field? || model.column_names.include?(field.to_s)
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
          table[field].send(cond, formatted_value) unless custom_field?
        end

        def text_search(value)
          casted_column.matches(value) unless custom_field?
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
          !column_integer_range.cover?(Integer(search_value))
        end

        # Range accepted for this column: keyed on the column's byte size when the
        # adapter exposes it (2/4/8), else the bigint range (permissive adapters
        # never raise; only PostgreSQL does, and it always reports the limit).
        def column_integer_range
          bytes = model.columns_hash[field.to_s]&.limit unless custom_field?
          INTEGER_RANGE_BY_BYTES[bytes] || INTEGER_RANGE_BY_BYTES[DEFAULT_INTEGER_BYTES]
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
