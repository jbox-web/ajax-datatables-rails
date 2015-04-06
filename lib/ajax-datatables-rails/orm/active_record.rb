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
        conditions = build_conditions_for(params[:search][:value])
        records = records.where(conditions) if conditions
        records
      end

      def composite_search(records)
        conditions = aggregate_query
        records = records.where(conditions) if conditions
        records
      end

      def build_conditions_for(query)
        search_for = query.split(' ')
        criteria = search_for.inject([]) do |criteria, atom|
          criteria << searchable_columns.map { |col| search_condition(col, atom) }
            .reduce(:or)
        end.reduce(:and)
        criteria
      end

      def aggregate_query
        conditions = view_columns.each_with_index.map do |column, index|
          value = params[:columns]["#{index}"][:search][:value] if params[:columns]
          search_condition(column, value) unless value.blank?
        end
        conditions.compact.reduce(:and)
      end

      def search_condition(column, value)
        model, column = column.split('.')
        table = get_table(model)
        casted_column = ::Arel::Nodes::NamedFunction.new(
          'CAST', [table[column.to_sym].as(typecast)]
        )

        casted_column.matches("%#{value}%")
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

      # ----------------- SORT HELPER METHODS --------------------

      def sort_column(item)
        model, column = view_columns[item[:column].to_i].split('.')
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
