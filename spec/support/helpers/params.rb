# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength, Layout/HashAlignment
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
          'data' => 'full_name', 'name' => '', 'searchable' => 'true', 'orderable' => 'true',
          'search' => {
            'value' => '', 'regex' => 'false'
          }
        },
        '5' => {
          'data' => 'post_id', 'name' => '', 'searchable' => 'true', 'orderable' => 'true',
          'search' => {
            'value' => '', 'regex' => 'false'
          }
        },
        '6' => {
          'data' => 'email_hash', 'name' => '', 'searchable' => 'false', 'orderable' => 'true',
          'search' => {
            'value' => '', 'regex' => 'false'
          }
        },
        '7' => {
          'data' => 'created_at', 'name' => '', 'searchable' => 'true', 'orderable' => 'true',
          'search' => {
            'value' => '', 'regex' => 'false'
          }
        },
      },
      'order' => {
        '0' => { 'column' => '0', 'dir' => 'asc' },
      },
      'start' => '0',
      'length' => '10',
      'search' => {
        'value' => '', 'regex' => 'false'
      },
      '_' => '1423364387185',
    }
  )
end
# rubocop:enable Metrics/MethodLength, Layout/HashAlignment

def sample_params_json
  hash_params = sample_params.to_unsafe_h
  hash_params['columns'] = hash_params['columns'].values
  hash_params['order'] = hash_params['order'].values
  ActionController::Parameters.new(hash_params)
end

# A form-encoded body reaches Rails as strings only; a JSON body preserves the
# native JS types, so a client posting `contentType: application/json` sends
# `order[].column` as an Integer rather than "0". sample_params_json only covers
# the array shape, still with string values — this helper covers the types too.
def sample_params_json_native
  hash_params = sample_params_json.to_unsafe_h

  %w[draw start length].each { |key| hash_params[key] = hash_params[key].to_i }
  hash_params['order']   = hash_params['order'].map { |order| json_native_order(order) }
  hash_params['columns'] = hash_params['columns'].map { |column| json_native_column(column) }

  ActionController::Parameters.new(hash_params)
end

def json_native_order(order)
  order.merge('column' => order['column'].to_i)
end

def json_native_column(column)
  column.merge(
    'searchable' => column['searchable'] == 'true',
    'orderable'  => column['orderable'] == 'true',
    'search'     => column['search'].merge('regex' => column['search']['regex'] == 'true')
  )
end

# Full ORDER BY fragment for one column when nulls-last is active, per adapter:
# a native `NULLS LAST` suffix on PostgreSQL/Oracle, a leading `IS NULL` key on
# MySQL/SQLite.
def nulls_last_term(datatable, column, direction)
  case datatable.db_adapter
  when :pg, :postgresql, :postgres, :oracle, :postgis
    "#{column} #{direction} NULLS LAST"
  when :mysql, :mysql2, :trilogy, :sqlite, :sqlite3
    "#{column} IS NULL, #{column} #{direction}"
  else
    raise 'unsupported database adapter'
  end
end
