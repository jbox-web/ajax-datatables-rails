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

### Model
Run the following command:

    rails generate ajaxdatatable <modelname>

This will generate a file in `app/datatables`
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
