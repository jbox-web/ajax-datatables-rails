module AjaxDatatablesRails
  module ORM
    module ActiveRecord

      def fetch_records
        get_raw_records
      end

      def filter_records records
        if datatable.searchable?
          simple_search records
        else
          composite_search records
        end
      end

      def sort_records records
        sort_by = connected_columns.each_with_object([]) do |(column, column_def), queries|
          order = datatable.order(:column_index, column.index)
          queries << order.query(column.sort_query) if order
        end
        records.order(sort_by.join(", "))
      end

      def paginate_records records
        records.offset(datatable.offset).limit(datatable.per_page)
      end

      # ----------------- SEARCH HELPER METHODS --------------------

      def simple_search records
        conditions = build_conditions_for_datatable
        conditions ? records.where(conditions) : records
      end

      def composite_search records
        conditions = aggregate_query
        conditions ? records.where(conditions) : records
      end

      def build_conditions_for_datatable
        search_for = datatable.search.value.split(' ')
        criteria = search_for.inject([]) do |criteria, atom|
          search = Datatable::SimpleSearch.new({ value: atom, regexp: datatable.search.regexp? })
          criteria << searchable_columns.map do |simple_column, column_def|
            simple_column.search = search
            simple_column.search_query
          end.reduce(:or)
        end.reduce(:and)
        criteria
      end

      def aggregate_query
        search_columns.map do |simple_column, column_def|
          simple_column.search_query
        end.reduce(:and)
      end

    end
  end
end
