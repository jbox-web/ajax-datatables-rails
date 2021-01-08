# frozen_string_literal: true

class DatatableCondEq < ComplexDatatable
  def view_columns
    super.deep_merge(post_id: { cond: :eq })
  end
end

class DatatableCondNotEq < ComplexDatatable
  def view_columns
    super.deep_merge(post_id: { cond: :not_eq })
  end
end

class DatatableCondLt < ComplexDatatable
  def view_columns
    super.deep_merge(post_id: { cond: :lt })
  end
end

class DatatableCondGt < ComplexDatatable
  def view_columns
    super.deep_merge(post_id: { cond: :gt })
  end
end

class DatatableCondLteq < ComplexDatatable
  def view_columns
    super.deep_merge(post_id: { cond: :lteq })
  end
end

class DatatableCondGteq < ComplexDatatable
  def view_columns
    super.deep_merge(post_id: { cond: :gteq })
  end
end

class DatatableCondIn < ComplexDatatable
  def view_columns
    super.deep_merge(post_id: { cond: :in })
  end
end

class DatatableCondInWithRegex < DatatableCondIn
  def view_columns
    super.deep_merge(post_id: { cond: :in, use_regex: false, orderable: true, formatter: ->(str) { cast_regex_value(str) } })
  end

  def cast_regex_value(value)
    value.split('|').map(&:to_i)
  end
end
