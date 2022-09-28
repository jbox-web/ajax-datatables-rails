# frozen_string_literal: true

class NamedJoinDatatable < AjaxDatatablesRails::ActiveRecord
  def view_columns
    @view_columns ||= {
      username:   { source: 'User.username' },
      group_name: { source: 'Group.name' },
      group_admin: { source: 'User.username', table_alias: 'admin' }
    }
  end

  def data
    records.map do |record|
      {
        username:   record.username,
        group_name: record.group&.name,
        group_admin: record.group&.admin&.username,
      }
    end
  end

  def get_raw_records
    User.left_outer_joins(group: :admin)
        .where(admin: { id: [nil, 1..] }) # Hack to force alias in Rails
  end
end
