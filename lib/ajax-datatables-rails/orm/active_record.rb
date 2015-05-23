module AjaxDatatablesRails
  module ORM
    module ActiveRecord
      def fetch_records
        get_raw_records
      end

      def filter_records(records)
        records = simple_search(records) if datatable.searchable?
        records = composite_search(records)
        records
      end

      def sort_records(records)
        sort_by = datatable.orders.each_with_object([]) do |order, queries|
          column = sort_column(order)
          queries << order.query(column) if column
        end
        records.order(sort_by.join(", "))
      end

      def paginate_records(records)
        records.offset(datatable.offset).limit(datatable.per_page)
      end

      # ----------------- SEARCH HELPER METHODS --------------------

      def simple_search(records)
        conditions = build_conditions_for_datatable
        conditions ? records.where(conditions) : records
      end

      def composite_search(records)
        conditions = aggregate_query
        conditions ? records.where(conditions) : records
      end

      def build_conditions_for_datatable
        search_for = datatable.search.value.split(' ')
        criteria = search_for.inject([]) do |criteria, atom|
          criteria << searchable_columns.map { |col| search_condition(col, atom, datatable.search.regexp?) }
            .reduce(:or)
        end.reduce(:and)
        criteria
      end

      def aggregate_query
        conditions = view_columns.map do |data_attr, column|
          simple_column = datatable.column(:data, data_attr)
          if simple_column && simple_column.searchable? && simple_column.search.value.present?
            search_condition(column, simple_column.search.value, simple_column.search.regexp?)
          end
        end
        conditions.compact.reduce(:and)
      end

      def search_condition(column, value, regex=false)
        model, column = column.split('.')
        table = get_table(model)
        regex ? regex_search(table, column, value) : non_regex_search(table, column, value)
      end

      def get_table(model)
        model.constantize.arel_table
      rescue
        table_from_downcased(model)
      end

      def table_from_downcased(model)
        model.singularize.titleize.gsub( / /, '' ).constantize.arel_table
      rescue
        ::Arel::Table.new(model.to_sym, ::ActiveRecord::Base)
      end

      def typecast
        case config.db_adapter
        when :mysql, :mysql2 then 'CHAR'
        when :sqlite, :sqlite3 then 'TEXT'
        else
          'VARCHAR'
        end
      end

      def regex_search(table, column, value)
        ::Arel::Nodes::Regexp.new(table[column.to_sym], ::Arel::Nodes.build_quoted(value))
      end

      def non_regex_search(table, column, value)
        casted_column = ::Arel::Nodes::NamedFunction.new(
          'CAST', [table[column.to_sym].as(typecast)]
        )
        casted_column.matches("%#{value}%")
      end

      # ----------------- SORT HELPER METHODS --------------------

      def sort_column(order)
        column = view_columns[order.column.data]
        if column
          model, column = column.split('.')
          table = get_table(model)
          [table.name, column].join('.')
        end
      end
    end
  end
end
