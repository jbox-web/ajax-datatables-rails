# frozen_string_literal: true

class DatatableOrderNullsLast < ComplexDatatable
  def view_columns
    super.deep_merge(email: { nulls_last: true })
  end
end
