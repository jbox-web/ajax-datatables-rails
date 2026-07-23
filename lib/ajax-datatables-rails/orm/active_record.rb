# frozen_string_literal: true

module AjaxDatatablesRails
  module ORM
    module ActiveRecord

      def filter_records(records)
        records.where(build_conditions)
      end

      # rubocop:disable Style/EachWithObject, Style/SafeNavigation
      def sort_records(records)
        sort_by = datatable.orders.inject([]) do |queries, order|
          column = order.column
          queries << order.query(column.sort_query) if column && column.orderable?
          queries
        end
        records.order(Arel.sql(sort_by.join(', ')))
      end
      # rubocop:enable Style/EachWithObject, Style/SafeNavigation

      def paginate_records(records)
        records.offset(datatable.offset).limit(datatable.per_page)
      end

      # ----------------- SEARCH HELPER METHODS --------------------

      # Final WHERE = (per-column searches) AND (global search box), each part
      # optional: reduce(:and) collapses the surviving Arel nodes and compact
      # drops whichever part produced nothing.
      def build_conditions
        @build_conditions ||= begin
          criteria = [build_conditions_for_selected_columns]
          criteria << build_conditions_for_datatable if datatable.searchable?
          criteria.compact.reduce(:and)
        end
      end

      # Global search (the single top-level search box). The value is split into
      # space-separated atoms; an atom matches when ANY searchable column matches
      # it (OR), and every atom must match (AND) — the classic "all words present,
      # anywhere" behaviour. Columns already filtered by their own per-column
      # search are excluded here. Each atom is fed through the column's existing
      # search_query builder by temporarily assigning `search=` (restored below).
      def build_conditions_for_datatable
        columns = searchable_columns.reject(&:searched?)
        preserving_search(columns) do
          search_for.filter_map do |atom|
            columns.filter_map do |simple_column|
              simple_column.search = Datatable::SimpleSearch.new(value: atom, regex: datatable.search.regexp?)
              simple_column.search_query
            end.reduce(:or)
          end.reduce(:and)
        end
      end

      # Runs the block, then restores each column's search, so the shared,
      # memoized Column objects are not left reporting a stale
      # `searched?`/`search.value` after a global search mutates them.
      def preserving_search(columns)
        originals = columns.map(&:search)
        yield
      ensure
        columns.each_with_index { |simple_column, i| simple_column.search = originals[i] }
      end

      # Per-column search: each column carrying its own search value contributes
      # one condition, all AND-ed together.
      def build_conditions_for_selected_columns
        search_columns.filter_map(&:search_query).reduce(:and)
      end

      # Split the global search box value into individual atoms (words) on the
      # delimiter, so multi-word searches are AND-ed term by term.
      def search_for
        datatable.search.value.split(global_search_delimiter)
      end

    end
  end
end
