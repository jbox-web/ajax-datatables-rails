module AjaxDatatablesRails
  module ORM
    module ActiveRecord
      def fetch_records
        get_raw_records
      end

      def filter_records(records)
        records = simple_search(records)
        records = composite_search(records)
        records
      end

      def sort_records(records)
        sort_by = []
        params[:order].each_value do |item|
          sort_by << "#{sort_column(item)} #{sort_direction(item)}"
        end
        records.order(sort_by.join(", "))
      end

      def paginate_records(records)
        records.offset(offset).limit(per_page)
      end

      # ----------------- SEARCH HELPER METHODS --------------------

      def simple_search(records)
        return records unless search_query_present?
        conditions = build_conditions_for(params[:search][:value], params[:search][:regex])
        records = records.where(conditions) if conditions
        records
      end

      def composite_search(records)
        conditions = aggregate_query
        records = records.where(conditions) if conditions
        records
      end

      def build_conditions_for(query, regex)
        search_for = query.split(' ')
        criteria = search_for.inject([]) do |criteria, atom|
          criteria << searchable_columns.map { |col| search_condition(col, atom, regex == 'true') }
            .reduce(:or)
        end.reduce(:and)
        criteria
      end

      def aggregate_query
        conditions = view_columns.map do |data_attr, column|
          searching_column = params[:columns].values.find { |col| col[:data] == data_attr }
          value = searching_column[:search][:value]           if searching_column
          regex = searching_column[:search][:regex] == 'true' if searching_column
          search_condition(column, value, regex) unless value.blank?
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

      def sort_column(item)
        model, column = view_columns[params[:columns][item[:column]][:data]].split('.')
        table = get_table(model)
        [table.name, column].join('.')
      end

      def sort_direction(item)
        options = %w(desc asc)
        options.include?(item[:dir]) ? item[:dir].upcase : 'ASC'
      end
    end
  end
end
