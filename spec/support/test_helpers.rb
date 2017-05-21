# rubocop:disable Metrics/MethodLength
def sample_params
  ActionController::Parameters.new(
    {
      'draw' => '1',
      'columns' => {
        '0' => {
          'data' => 'username', 'name' => '', 'searchable' => 'true', 'orderable' => 'true',
          'search' => {
            'value' => '', 'regex' => 'false'
          }
        },
        '1' => {
          'data' => 'email', 'name' => '', 'searchable' => 'true', 'orderable' => 'true',
          'search' => {
            'value' => '', 'regex' => 'false'
          }
        },
        '2' => {
          'data' => 'first_name', 'name' => '', 'searchable' => 'true', 'orderable' => 'false',
          'search' => {
            'value' => '', 'regex' => 'false'
          }
        },
        '3' => {
          'data' => 'last_name', 'name' => '', 'searchable' => 'true', 'orderable' => 'true',
          'search' => {
            'value' => '', 'regex' => 'false'
          }
        },
        '4' => {
          'data' => 'post_id', 'name' => '', 'searchable' => 'true', 'orderable' => 'true',
          'search' => {
            'value' => '', 'regex' => 'false'
          }
        },
        '5' => {
          'data' => 'created_at', 'name' => '', 'searchable' => 'true', 'orderable' => 'true',
          'search' => {
            'value' => '', 'regex' => 'false'
          }
        },
      },
      'order' => {
        '0' => {'column' => '0', 'dir' => 'asc'}
      },
      'start' => '0', 'length' => '10', 'search' => {
        'value' => '', 'regex' => 'false'
      },
      '_' => '1423364387185'
    }
  )
end
# rubocop:enable Metrics/MethodLength

class SampleDatatable < AjaxDatatablesRails::Base
  def view_columns
    @view_columns ||= ['User.username', 'User.email', 'User.first_name', 'User.last_name']
  end

  def data
    [{}, {}]
  end

  def get_raw_records
    User.all
  end
end

class ComplexDatatable < SampleDatatable
  def view_columns
    @view_columns ||= {
      username:   { source: 'User.username' },
      email:      { source: 'User.email' },
      first_name: { source: 'User.first_name' },
      last_name:  { source: 'User.last_name', formater: -> (o) { o.upcase } },
    }
  end

  def data
    records.map do |record|
      {
        username:   record.username,
        email:      record.email,
        first_name: record.first_name,
        last_name:  record.last_name,
      }
    end
  end
end

class ComplexDatatableHash < ComplexDatatable
end

class ComplexDatatableArray < ComplexDatatable
  def data
    records.map do |record|
      [
        record.username,
        record.email,
        record.first_name,
        record.last_name,
      ]
    end
  end
end

class ReallyComplexDatatable < SampleDatatable
  def view_columns
    @view_columns ||= {
      username:   { source: 'User.username' },
      email:      { source: 'User.email',      cond: :null_value },
      first_name: { source: 'User.first_name', cond: :start_with },
      last_name:  { source: 'User.last_name',  cond: :end_with, formater: -> (o) { o.upcase } },
      post_id:    { source: 'User.post_id' },
      created_at: { source: 'User.created_at', cond: :date_range },
    }
  end

  def data
    records.map do |record|
      {
        username:   record.username,
        email:      record.email,
        first_name: record.first_name,
        last_name:  record.last_name,
        post_id:    record.post_id,
        created_at: record.created_at,
      }
    end
  end
end

class ReallyComplexDatatableEq < ReallyComplexDatatable
  def view_columns
    super.deep_merge(post_id: { cond: :eq })
  end
end

class ReallyComplexDatatableNotEq < ReallyComplexDatatable
  def view_columns
    super.deep_merge(post_id: { cond: :not_eq })
  end
end

class ReallyComplexDatatableLt < ReallyComplexDatatable
  def view_columns
    super.deep_merge(post_id: { cond: :lt })
  end
end

class ReallyComplexDatatableGt < ReallyComplexDatatable
  def view_columns
    super.deep_merge(post_id: { cond: :gt })
  end
end

class ReallyComplexDatatableLteq < ReallyComplexDatatable
  def view_columns
    super.deep_merge(post_id: { cond: :lteq })
  end
end

class ReallyComplexDatatableGteq < ReallyComplexDatatable
  def view_columns
    super.deep_merge(post_id: { cond: :gteq })
  end
end

class ReallyComplexDatatableIn < ReallyComplexDatatable
  def view_columns
    super.deep_merge(post_id: { cond: :in })
  end
end
