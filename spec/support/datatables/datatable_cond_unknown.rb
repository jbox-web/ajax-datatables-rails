class DatatableCondUnknown < ComplexDatatable
  def view_columns
    super.deep_merge(username: { cond: :foo })
  end
end
