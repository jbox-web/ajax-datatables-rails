# frozen_string_literal: true

class DatatableCondProc < ComplexDatatable
  def view_columns
    super.deep_merge(username: { cond: custom_filter })
  end

  private

  def custom_filter
    ->(column, value) { ::Arel::Nodes::SqlLiteral.new(column.field.to_s).matches("#{value}%") }
  end
end
