class DatatableCondStartWith < ComplexDatatable
  def view_columns
    super.deep_merge(first_name: { cond: :start_with })
  end
end

class DatatableCondEndWith < ComplexDatatable
  def view_columns
    super.deep_merge(last_name: { cond: :end_with })
  end
end

class DatatableCondNullValue < ComplexDatatable
  def view_columns
    super.deep_merge(email: { cond: :null_value })
  end
end

class DatatableWithFormater < ComplexDatatable
  def view_columns
    super.deep_merge(last_name: { formater: -> (o) { o.upcase } })
  end
end
