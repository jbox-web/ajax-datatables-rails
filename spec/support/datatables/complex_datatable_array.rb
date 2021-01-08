# frozen_string_literal: true

class ComplexDatatableArray < ComplexDatatable
  def data
    records.map do |record|
      [
        record.username,
        record.email,
        record.first_name,
        record.last_name,
        record.post_id,
        record.created_at,
      ]
    end
  end
end
