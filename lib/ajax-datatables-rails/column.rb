module AjaxDatatablesRails
  class Column

    # Abstraction around a column or attribute field on an ActiveRecord object
    #
    # ==== Attributes
    #
    # * +model+ - The ActiveRecord model with the column to be filtered
    # * +column+ - The column name to filter
    # * +db_adapter+ - The database adapter symbol
    #
    def initialize(model, column, db_adapter)
      @model = model
      @column = column
      @db_adapter = db_adapter
    end

    def ==(other)
      other.class == self.class && other.state == self.state
    end

    # Returns an Arel object for generating a SQL query condition to filter the returned records according
    # to the provided value.
    #
    # ==== Arguments
    #
    # * +value+ - The value for which to create the filter condition
    #
    def filter_condition(value)
      fail MethodNotImplementedError, 'Must be implemented in subclass.'
    end

    # Returns an Arel object for generating a SQL order statement in the specified direction.
    #
    # ==== Arguments
    #
    # * +direction+ - The direction the records should be ordered
    #
    def order_condition(direction)
      fail MethodNotImplementedError, 'Must be implemented in subclass.'
    end

    # Construct and returns a filter for reducing records via query. If the provided +value+ is blank, then nil is
    # returned instead.
    #
    # ==== Arguments
    #
    # * +column+ - The String column definition in the nme format as provided to searchable_columns
    # * +value+ - The value for which to create the filter condition
    # * +db_adapter+ - The database adapter symbol
    #
    def self.from_string(column, db_adapter)
      model, column_name = if column[0] == column.downcase[0]
        message = '[DEPRECATED] Using table_name.column_name notation is deprecated. Please refer to: ' +
          'https://github.com/antillas21/ajax-datatables-rails#searchable-and-sortable-columns-syntax'
        ::AjaxDatatablesRails::Base.deprecated(message)

        parsed_model, parsed_column = column.split('.')
        model_name = parsed_model.singularize.titleize.gsub( / /, '' )
        [model_name, parsed_column]
      else
        column.split('.')
      end

      model_class = model.constantize
      if EnumColumn.column_is_enum?(model_class, column_name)
        EnumColumn.new(model_class, column_name, db_adapter)
      else
        StandardColumn.new(model_class, column_name, db_adapter)
      end
    end

    protected

    def arel_attribute
      @model.arel_table[@column.to_sym]
    end

    def state
      [@model, @column, @db_adapter]
    end
  end

  # Wrapper specific for ActiveRecord enum columns
  class EnumColumn < Column
    def filter_condition(value)
      if value.blank? then nil
      else
        # Identify the numeric values to search
        db_values = value_map.select { |label, db_value| label =~ /#{Regexp.escape(value)}/i }.values
        arel_attribute.in(db_values)
      end
    end

    def order_condition(direction)
      # Determine the relative ordering of the enum fields
      ascending_values = value_map.sort_by { |label, db_value| label }.map { |label, db_value| db_value }
      raise "unknown sort direction #{direction} provided" unless [:asc, :desc].include?(direction)

      # Construct the custom SQL for the sort
      escaped_column_name = "\"#{arel_attribute.relation.name}\".\"#{arel_attribute.name}\""
      order_sql = ascending_values.each_with_index.reduce('CASE ') do |sql, (value, order)|
        sql += "WHEN #{escaped_column_name} = #{value} THEN #{order} "
      end
      order_sql += "ELSE #{escaped_column_name} END #{direction.upcase}"

      Arel::Nodes::SqlLiteral.new(order_sql)
    end

    def self.column_is_enum?(model, column)
      model.respond_to?(:defined_enums) && model.defined_enums.include?(column.to_s)
    end

    private

    def value_map
      @model.send(@column.to_s.pluralize)
    end
  end

  class StandardColumn < Column
    def filter_condition(value)
      if value.blank? then nil
      else
        casted_column = ::Arel::Nodes::NamedFunction.new('CAST', [arel_attribute.as(text_typecast)])
        casted_column.matches("%#{value}%")
      end
    end

    def order_condition(direction)
      case direction
        when :asc then arel_attribute.asc
        when :desc then arel_attribute.desc
        else raise "unknown sort direction #{direction} provided"
      end
    end

    private

    def text_typecast
      case @db_adapter
        when :oracle then 'VARCHAR2(4000)'
        when :pg then 'VARCHAR'
        when :mysql2 then 'CHAR'
        when :sqlite3 then 'TEXT'
      end
    end
  end
end