# frozen_string_literal: true

class GroupedDatatable < ComplexDatatable

  def get_raw_records
    User.all.group(:id)
  end
end
