# frozen_string_literal: true

class DatatableCondDate < ComplexDatatable
  def view_columns
    super.deep_merge(created_at: { cond: :date_range })
  end
end
