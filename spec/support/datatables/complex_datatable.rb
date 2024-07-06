# frozen_string_literal: true

class ComplexDatatable < AjaxDatatablesRails::ActiveRecord
  def view_columns
    @view_columns ||= {
      username:   { source: 'User.username'   },
      email:      { source: 'User.email'      },
      first_name: { source: 'User.first_name' },
      last_name:  { source: 'User.last_name'  },
      full_name:  { source: 'full_name' },
      post_id:    { source: 'User.post_id', orderable: false },
      email_hash: { source: 'email_hash', searchable: false },
      created_at: { source: 'User.created_at' },
    }
  end

  def data
    records.map do |record|
      {
        username:   record.username,
        email:      record.email,
        first_name: record.first_name,
        last_name:  record.last_name,
        full_name:  record.full_name,
        post_id:    record.post_id,
        email_hash: record.email_hash,
        created_at: record.created_at,
      }
    end
  end

  def get_raw_records
    User.all
  end
end
