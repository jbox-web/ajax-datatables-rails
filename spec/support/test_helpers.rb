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

class ComplexDatatable < AjaxDatatablesRails::ActiveRecord
  def view_columns
    @view_columns ||= {
      username:   { source: 'User.username'   },
      email:      { source: 'User.email'      },
      first_name: { source: 'User.first_name' },
      last_name:  { source: 'User.last_name'  },
      post_id:    { source: 'User.post_id', orderable: false },
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
        post_id:    record.post_id,
        created_at: record.created_at,
      }
    end
  end

  def get_raw_records
    User.all
  end
end

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
