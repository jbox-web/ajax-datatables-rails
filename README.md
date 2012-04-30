# ajax-datatables-rails

Datatables is a nifty jquery plugin that adds the ability to paginate, sort, and search your html tables. When dealing with large tables (more than a couple hundred rows) however, we run into performance issues. These can be fixed by using server-side pagination, but this breaks some datatables functionality.

`ajax-datatables-rails` is a wrapper around datatable's ajax methods that allow synchronization with server-side pagination in a rails app. 

## Installation

Add these lines to your application's Gemfile:

    gem 'jquery-datatables-rails'
    gem 'ajax-datatables-rails'

And then execute:

    $ bundle

## Usage
*The following examples assume that we are setting up ajax-datatables-rails for an index of users from a `User` model*
### Model
Run the following command:

    $ rails generate ajaxdatatable User

This will generate a file named `users_datatable.rb` in `app/datatables`. Open the file and customize in the functions as directed by the comments

#### Initializer
```ruby
def initialize(view)
  @model_name = User
  @columns = # insert array of column names here
  @searchable_columns = #insert array of columns that will be searched
  super(view)
end
```

For `@columns`, assign an array of the database columns that correspond to the columns in our view table. For example `[users.f_name, users.l_name, users.bio]`. This array is used for sorting by various columns

For `@searchable_columns`, assign an array of the database columns that you want searchable by datatables. For example `[users.f_name, users.l_name]`

This gives us: 
```ruby
def initialize(view)
  @model_name = User
  @columns = [users.f_name, users.l_name, users.bio]
  @searchable_columns = [users.f_name, users.l_name]
  super(view)
end
```

#### Data
```ruby
def data
  users.map do |user|
    [
      # comma separated list of the values for each cell of a table row
    ]
  end
end
```

This method builds a 2d array that is used by datatables to construct the html table. Insert the values you want on each column.

```ruby
def data
  users.map do |user|
    [
      user.f_name,
      user.l_name,
      user.bio
    ]
  end
end
```

#### Get Raw Records
```ruby
def get_raw_records
  # insert query here
end
```

This is where your query goes.

```ruby
def get_raw_records
  User.all
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
