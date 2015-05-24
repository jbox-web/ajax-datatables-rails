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
        sort_by = connected_columns.each_with_object([]) do |(column, column_def), queries|
          order = datatable.order(:column_index, column.index)
          queries << order.query(sort_column(column_def)) if order
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
          criteria << searchable_columns.map { |_, column_def| search_condition(column_def, atom, datatable.search.regexp?) }
            .reduce(:or)
        end.reduce(:and)
        criteria
      end

      def aggregate_query
        search_columns.map do |simple_column, column_def|
          search_condition(column_def, simple_column.search.value, simple_column.search.regexp?)
        end.reduce(:and)
      end

      def search_condition(column_def, value, regex=false)
        table, column = table_column_for column_def
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

      def sort_column(column_def)
        table, column = table_column_for(column_def)
        [table.name, column].join('.')
      end

      def table_column_for column_def
        model, column = column_def.split('.')
        table = get_table(model)
        [table, column]
      end
    end
  end
end
