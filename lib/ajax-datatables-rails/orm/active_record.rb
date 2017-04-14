module AjaxDatatablesRails
  module ORM
    module ActiveRecord

      def fetch_records
        get_raw_records
      end

      def filter_records(records)
        records.where(build_conditions)
      end

      def sort_records(records)
        sort_by = datatable.orders.inject([]) do |queries, order|
          column = order.column
          queries << order.query(column.sort_query) if column
        end
        records.order(sort_by.join(", "))
      end

      def paginate_records(records)
        records.offset(datatable.offset).limit(datatable.per_page)
      end

      # ----------------- SEARCH HELPER METHODS --------------------

      def build_conditions
        if datatable.searchable?
          build_conditions_for_datatable
        else
          build_conditions_for_selected_columns
        end
      end

      def build_conditions_for_datatable
        search_for = datatable.search.value.split(' ')
        criteria = search_for.inject([]) do |crit, atom|
          search = Datatable::SimpleSearch.new({ value: atom, regex: datatable.search.regexp? })
          crit << searchable_columns.map do |simple_column|
            simple_column.search = search
            simple_column.search_query
          end.reduce(:or)
        end.reduce(:and)
        criteria
      end

      def build_conditions_for_selected_columns
        search_columns.map(&:search_query).compact.reduce(:and)
      end
    end
  end
end
