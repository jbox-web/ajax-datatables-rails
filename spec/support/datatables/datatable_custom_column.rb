# frozen_string_literal: true

class DatatableCustomColumn < ComplexDatatable
  def view_columns
    super.deep_merge(full_name: { cond: filter_full_name })
  end

  def get_raw_records
    User.select("*, CONCAT(first_name, ' ', last_name) as full_name")
  end

  private

  def filter_full_name
    ->(_column, value) { ::Arel::Nodes::SqlLiteral.new("CONCAT(first_name, ' ', last_name)").matches("#{value}%") }
  end
end
