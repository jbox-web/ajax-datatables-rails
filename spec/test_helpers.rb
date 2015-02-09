def sample_params
  ActiveSupport::HashWithIndifferentAccess.new(
    {
      "draw"=>"1",
      "columns"=> {
        "0"=> {
          "data"=>"0", "name"=>"", "searchable"=>"true", "orderable"=>"true",
          "search"=> {
            "value"=>"", "regex"=>"false"
          }
        },
        "1"=> {
          "data"=>"1", "name"=>"", "searchable"=>"true", "orderable"=>"true",
          "search"=> {
            "value"=>"", "regex"=>"false"
          }
        },
        "2"=> {
          "data"=>"2", "name"=>"", "searchable"=>"false", "orderable"=>"false",
          "search"=> {
            "value"=>"", "regex"=>"false"
          }
        },
        "3"=> {
          "data"=>"3", "name"=>"", "searchable"=>"false", "orderable"=>"true",
          "search"=> {
            "value"=>"", "regex"=>"false"
          }
        },
      },
      "order"=> {
        "0"=> {"column"=>"0", "dir"=>"asc"}
      },
      "start"=>"0", "length"=>"10", "search"=>{
        "value"=>"", "regex"=>"false"
      },
      "_"=>"1423364387185"
    }
  )
end

class SampleDatatable < AjaxDatatablesRails::Base
  def view_columns
    @view_columns ||= [
      'User.username', 'User.email', 'User.first_name', 'User.last_name'
    ]
  end

  def data
    [{}, {}]
  end

  def get_raw_records
    User.all
  end
end
