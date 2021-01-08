# frozen_string_literal: true

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

class DatatableCondLike < ComplexDatatable
  def view_columns
    super.deep_merge(email: { cond: :like })
  end
end

class DatatableCondStringEq < ComplexDatatable
  def view_columns
    super.deep_merge(email: { cond: :string_eq })
  end
end

class DatatableCondStringIn < ComplexDatatable
  def view_columns
    super.deep_merge(email: { cond: :string_in, formatter: ->(o) { o.split('|') } })
  end
end

class DatatableCondNullValue < ComplexDatatable
  def view_columns
    super.deep_merge(email: { cond: :null_value })
  end
end

class DatatableWithFormater < ComplexDatatable
  def view_columns
    super.deep_merge(last_name: { formatter: ->(o) { o.upcase } })
  end
end
