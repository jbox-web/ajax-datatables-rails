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
        fail(
          NotImplemented,
          'Please mixin a pagination extension.'
        )
      end

      # ----------------- SEARCH METHODS --------------------

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

      def search_condition(column, value)
        if column[0] == column.downcase[0]
          ::AjaxDatatablesRails::Base.deprecated '[DEPRECATED] Using table_name.column_name notation is deprecated. Please refer to: https://github.com/antillas21/ajax-datatables-rails#searchable-and-sortable-columns-syntax'
          return deprecated_search_condition(column, value)
        else
          return new_search_condition(column, value)
        end
      end

      def new_search_condition(column, value)
        model, column = column.split('.')
        model = model.constantize
        casted_column = ::Arel::Nodes::NamedFunction.new('CAST', [model.arel_table[column.to_sym].as(typecast)])
        casted_column.matches("%#{value}%")
      end

      def deprecated_search_condition(column, value)
        model, column = column.split('.')
        model = model.singularize.titleize.gsub( / /, '' ).constantize

        casted_column = ::Arel::Nodes::NamedFunction.new('CAST', [model.arel_table[column.to_sym].as(typecast)])
        casted_column.matches("%#{value}%")
      end

      def aggregate_query
        conditions = searchable_columns.each_with_index.map do |column, index|
          value = params[:columns]["#{index}"][:search][:value] if params[:columns]
          search_condition(column, value) unless value.blank?
        end
        conditions.compact.reduce(:and)
      end

      def typecast
        case config.db_adapter
        when :mysql, :mysql2 then 'CHAR'
        when :sqlite, :sqlite3 then 'TEXT'
        else
          'VARCHAR'
        end
      end

      # ----------------- PAGINATION METHODS --------------------

      def offset
        (page - 1) * per_page
      end

      def page
        (params[:start].to_i / per_page) + 1
      end

      def per_page
        params.fetch(:length, 10).to_i
      end

      # ----------------- SORT METHODS --------------------

      def sort_column(item)
        new_sort_column(item)
      rescue
        ::AjaxDatatablesRails::Base.deprecated '[DEPRECATED] Using table_name.column_name notation is deprecated. Please refer to: https://github.com/antillas21/ajax-datatables-rails#searchable-and-sortable-columns-syntax'
        deprecated_sort_column(item)
      end

      def deprecated_sort_column(item)
        sortable_columns[sortable_displayed_columns.index(item[:column])]
      end

      def new_sort_column(item)
        model, column = sortable_columns[sortable_displayed_columns.index(item[:column])].split('.')
        col = [model.constantize.table_name, column].join('.')
      end

      def sort_direction(item)
        options = %w(desc asc)
        options.include?(item[:dir]) ? item[:dir].upcase : 'ASC'
      end
    end
  end
end
