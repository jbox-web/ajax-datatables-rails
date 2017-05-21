# ajax-datatables-rails

[![GitHub license](https://img.shields.io/github/license/jbox-web/ajax-datatables-rails.svg)](https://github.com/jbox-web/ajax-datatables-rails/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/ajax-datatables-rails.svg)](https://rubygems.org/gems/ajax-datatables-rails)
[![Gem](https://img.shields.io/gem/dtv/ajax-datatables-rails.svg)](https://rubygems.org/gems/ajax-datatables-rails)
[![Build Status](https://travis-ci.org/jbox-web/ajax-datatables-rails.svg?branch=master)](https://travis-ci.org/jbox-web/ajax-datatables-rails)
[![Code Climate](https://codeclimate.com/github/jbox-web/ajax-datatables-rails/badges/gpa.svg)](https://codeclimate.com/github/jbox-web/ajax-datatables-rails)
[![Test Coverage](https://codeclimate.com/github/jbox-web/ajax-datatables-rails/badges/coverage.svg)](https://codeclimate.com/github/jbox-web/ajax-datatables-rails/coverage)
[![Dependency Status](https://gemnasium.com/jbox-web/ajax-datatables-rails.svg)](https://gemnasium.com/jbox-web/ajax-datatables-rails)

> __Important__
>
> This gem is targeted at Datatables version 1.10.x.
>
> It's tested against :
> * Rails 4.0.13 / 4.1.15 / 4.2.8 / 5.0.2 / 5.1.0
> * Ruby 2.2.7 / 2.3.4 / 2.4.1
> * Postgresql
> * MySQL
> * Oracle XE 11.2 (thanks to [travis-oracle](https://github.com/cbandy/travis-oracle))

## Description

Datatables is a nifty jquery plugin that adds the ability to paginate, sort,
and search your html tables. When dealing with large tables
(more than a couple hundred rows) however, we run into performance issues.
These can be fixed by using server-side pagination, but this breaks some
datatables functionality.

`ajax-datatables-rails` is a wrapper around datatable's ajax methods that allow
synchronization with server-side pagination in a rails app. It was inspired by
this [Railscast](http://railscasts.com/episodes/340-datatables). I needed to
implement a similar solution in a couple projects I was working on, so I
extracted a solution into a gem.

## ORM support

Currently `AjaxDatatablesRails` only supports `ActiveRecord` as ORM for
performing database queries.

Adding support for `Sequel`, `Mongoid` and `MongoMapper` is a planned feature
for this gem. If you'd be interested in contributing to speed development,
please [open an issue](https://github.com/antillas21/ajax-datatables-rails/issues/new)
and get in touch.

## Installation

Add these lines to your application's Gemfile:

```ruby
gem 'jquery-datatables-rails'
gem 'ajax-datatables-rails'
```

And then execute:

```sh
$ bundle
```

The `jquery-datatables-rails` gem is listed as a convenience, to ease adding
jQuery dataTables to your Rails project. You can always add the plugin assets
manually via the assets pipeline. If you decide to use the
`jquery-datatables-rails` gem, please refer to its installation instructions
[here](https://github.com/rweng/jquery-datatables-rails).


## Usage

*The following examples assume that we are setting up ajax-datatables-rails for
an index page of users from a `User` model, and that we are using postgresql as
our db, because you __should be using it__, if not, please refer to the
[Searching on non text-based columns](#searching-on-non-text-based-columns)
entry in the Additional Notes section.*


### Generate

Run the following command:

```sh
$ rails generate datatable User
```

This will generate a file named `user_datatable.rb` in `app/datatables`.
Open the file and customize in the functions as directed by the comments.

Take a look [here](#generator-syntax) for an explanation about the generator syntax.


### Build the View

You should always start by the single source of truth, which is your html view. Suppose we need to render a users table and display: first name, last name, and bio for each user.

Something like this:

|First Name|Last Name|Brief Bio|
|----------|---------|---------|
|John      |Doe      |Is your default user everywhere|
|Jane      |Doe      |Is John's wife|
|James     |Doe      |Is John's brother and best friend|


* Set up an html `<table>` with a `<thead>` and `<tbody>`
* Add in your table headers if desired
* Don't add any rows to the body of the table, datatables does this automatically
* Add a data attribute to the `<table>` tag with the url of the JSON feed, in our case is the `users_path` as we're pointing to the `UsersController#index` action


```html
<table id="users-table", data-source="<%= users_path(format: :json) %>">
  <thead>
    <tr>
      <th>First Name</th>
      <th>Last Name</th>
      <th>Brief Bio</th>
    </tr>
  </thead>
  <tbody>
  </tbody>
</table>
```


### Customize the generated Datatables class

```ruby
def view_columns
  # Declare strings in this format: ModelName.column_name
  # or in aliased_join_table.column_name format
  @view_columns ||= {}
end
```

* In this method, add a list of the model(s) columns mapped to the data you need to present. In this case: `first_name`, `last_name` and `bio`.

This gives us:

```ruby
def view_columns
  @view_columns ||= {
    first_name: { source: "User.first_name", cond: :like, searchable: true, orderable: true },
    last_name:  { source: "User.last_name",  cond: :like },
    bio:        { source: "User.bio" },
  }
end
```

**Notes :** by default `orderable` and `searchable` are true and `cond` is `:like`.

`cond` can be :

* `:like`, `:start_with`, `:end_with` for string or full text search
* `:eq`, `:not_eq`, `:lt`, `:gt`, `:lteq`, `:gteq`, `:in` for numeric
* `:date_range` for date range (only for Rails > 4.2.x)
* `:null_value` for nil field
* `Proc` for whatever

[See here](#searching-on-non-text-based-columns) for notes about the `view_columns` settings (if using something different from `postgres`).
[Read these notes](#columns-syntax) about considerations for the `view_columns` method.


#### Map data

```ruby
def data
  records.map do |record|
    {
      # a hash of key value pairs
    }
  end
end
```

```ruby
def data
  records.map do |record|
    {
      first_name: record.first_name,
      last_name:  record.last_name,
      bio:        record.bio,
      # 'DT_RowId' => record.id, # This will set the id attribute on the corresponding <tr> in the datatable
    }
  end
end
```

You can either use the v0.3 Array style for your columns :

```ruby
def data
  records.map do |record|
    [
      # comma separated list of the values for each cell of a table row
      # example: record.first_name, record.last_name
    ]
  end
end
```

This method builds a 2d array that is used by datatables to construct the html
table. Insert the values you want on each column.

```ruby
def data
  records.map do |record|
    [
      record.first_name,
      record.last_name,
      record.bio
    ]
  end
end
```

[See here](#using-view-helpers) if you need to use view helpers like `link_to`, `mail_to`, `resource_path`, etc.


#### Get Raw Records

```ruby
def get_raw_records
  # insert query here
end
```

This is where your query goes.

```ruby
def get_raw_records
  # suppose we need all User records
  # Rails 4+
  User.all
  # Rails 3.x
  # User.scoped
end
```

Obviously, you can construct your query as required for the use case the datatable is used.

Example:

```ruby
def get_raw_records
  User.active.with_recent_messages
end
```

You can put any logic in `get_raw_records` [based on any parameters you inject](#options) in the `Datatable` object.

> __IMPORTANT:__ Make sure to return an `ActiveRecord::Relation` object
> as the end product of this method.
>
> Why? Because the result from this method, will be chained (for now)
> to `ActiveRecord` methods for sorting, filtering and pagination.


#### Associated and nested models

The previous example has only one single model. But what about if you have
some associated nested models and in a report you want to show fields from
these tables.

Take an example that has an `Event, Course, Coursetype, Allocation, Teacher,
Contact, Competency and CompetencyType` models. We want to have a datatables
report which has the following column:

```ruby
'coursetypes.name',
'courses.name',
'events.title',
'events.event_start',
'events.event_end',
'contacts.full_name',
'competency_types.name',
'events.status'
```

We want to sort and search on all columns of the list. The related definition
would be:

```ruby
def view_columns
  @view_columns ||= [
    'Coursetype.name',
    'Course.name',
    'Event.title',
    'Event.event_start',
    'Event.event_end',
    'Contact.last_name',
    'CompetencyType.name',
    'Event.status'
  ]
end

def get_raw_records
   Event.joins(
    { course: :coursetype },
    { allocations: {
        teacher: [:contact, {competencies: :competency_type}]
      }
    }).distinct
end
```

__Some comments for the above code:__

1. In the `get_raw_records` method we have quite a complex query having one to
many and may to many associations using the joins ActiveRecord method.
The joins will generate INNER JOIN relations in the SQL query. In this case,
we do not include all event in the report if we have events which is not
associated with any model record from the relation.

2. To have all event records in the list we should use the `.includes` method,
which generate LEFT OUTER JOIN relation of the SQL query.
__IMPORTANT:__ Make sure to append `.references(:related_model)` with any
associated model. That forces the eager loading of all the associated models
by one SQL query, and the search condition for any column works fine.
Otherwise the `:recordsFiltered => filter_records(get_raw_records).count(:all)`
will generate 2 SQL queries (one for the Event model, and then another for the
associated tables). The `:recordsFiltered => filter_records(get_raw_records).count(:all)`
will use only the first one to return from the ActiveRecord::Relation object
in `get_raw_records` and you will get an error message of __Unknown column
'yourtable.yourfield' in 'where clause'__ in case the search field value
is not empty.

So the query using the `.includes()` method is:

```ruby
def get_raw_records
   Event.includes(
    { course: :coursetype },
    { allocations: {
        teacher: [:contact, { competencies: :competency_type }]
      }
    }
    ).references(:course).distinct
end
```


#### Additional datas

You can inject other key/value pairs in the rendered JSON by defining the `#additional_datas` method :

```ruby
def additional_datas
  {
    foo: 'bar'
  }
end
```

Very useful with https://github.com/vedmack/yadcf to provide values for dropdown filters.


### Setup the Controller action

Set the controller to respond to JSON

```ruby
def index
  respond_to do |format|
    format.html
    format.json { render json: UserDatatable.new(view_context) }
  end
end
```

Don't forget to make sure the proper route has been added to `config/routes.rb`.

[See here](#options) to inject params in the `UserDatatable`.

### Wire up the Javascript

Finally, the javascript to tie this all together. In the appropriate `coffee` file:

```coffeescript
# users.coffee

$ ->
  $('#users-table').dataTable
    processing: true
    serverSide: true
    ajax: $('#users-table').data('source')
    pagingType: 'full_numbers'
    # optional, if you want full pagination controls.
    # Check dataTables documentation to learn more about
    # available options.
```

or, if you're using plain javascript:
```javascript
// users.js

jQuery(document).ready(function() {
  $('#users-table').dataTable({
    "processing": true,
    "serverSide": true,
    "ajax": $('#users-table').data('source'),
    "pagingType": "full_numbers",
    // optional, if you want full pagination controls.
    // Check dataTables documentation to learn more about
    // available options.
  });
});
```


### Additional Notes

#### Columns syntax

Since version `0.3.0`, we are implementing a pseudo code way of declaring
the array columns to use when querying the database.

Example. Suppose we have the following models: `User`, `PurchaseOrder`,
`Purchase::LineItem` and we need to have several columns from those models
available in our datatable to search and sort by.

```ruby
# we use the ModelName.column_name notation to declare our columns

def view_columns
  @view_columns ||= [
    'User.first_name',
    'User.last_name',
    'PurchaseOrder.number',
    'PurchaseOrder.created_at',
    'Purchase::LineItem.quantity',
    'Purchase::LineItem.unit_price',
    'Purchase::LineItem.item_total'
  ]
end
```


#### What if the datatable itself is namespaced?

Example: what if the datatable is namespaced into an `Admin` module?

```ruby
module Admin
  class PurchasesDatatable < AjaxDatatablesRails::Base
  end
end
```

Taking the same models and columns, we would define it like this:

```ruby
def view_columns
  @view_columns ||= [
    '::User.first_name',
    '::User.last_name',
    '::PurchaseOrder.number',
    '::PurchaseOrder.created_at',
    '::Purchase::LineItem.quantity',
    '::Purchase::LineItem.unit_price',
    '::Purchase::LineItem.item_total'
  ]
end
```

Pretty much like you would do it, if you were inside a namespaced controller.


#### Searching on non text-based columns

It always comes the time when you need to add a non-string/non-text based
column to the `@view_columns` array, so you can perform searches against
these column types (example: numeric, date, time).

We recently added the ability to (automatically) typecast these column types
and have this scenario covered. Please note however, if you are using
something different from `postgresql` (with the `:pg` gem), like `mysql` or
`sqlite`, then you need to add an initializer in your application's
`config/initializers` directory.

If you don't perform this step (again, if using something different from
`postgresql`), your database will complain that it does not understand the
default typecast used to enable such searches.


#### Configuration initializer

You have two options to create this initializer:

* use the provided (and recommended) generator (and then just edit the file);
* create the file from scratch.

To use the generator, from the terminal execute:

```sh
$ bundle exec rails generate datatable:config
```

Doing so, will create the `config/initializers/ajax_datatables_rails.rb` file
with the following content:

```ruby
AjaxDatatablesRails.configure do |config|
  # available options for db_adapter are: :pg, :mysql, :mysql2, :sqlite, :sqlite3
  # config.db_adapter = :pg

  # available options for orm are: :active_record, :mongoid
  # config.orm = :active_record
end
```

Uncomment the `config.db_adapter` line and set the corresponding value to your
database and gem. This is all you need.

Uncomment the `config.orm` line to set `active_record or mongoid` if
included in your project. It defaults to `active_record`.

If you want to make the file from scratch, just copy the above code block into
a file inside the `config/initializers` directory.


#### Using view helpers

Sometimes you'll need to use view helper methods like `link_to`, `h`, `mailto`,
`edit_resource_path` in the returned JSON representation returned by the `data`
method.

To have these methods available to be used, this is the way to go:

```ruby
class MyCustomDatatable < AjaxDatatablesRails::Base
  # either define them one-by-one
  def_delegator :@view, :link_to
  def_delegator :@view, :h
  def_delegator :@view, :mail_to

  # or define them in one pass
  def_delegators :@view, :link_to, :h, :mailto, :edit_resource_path, :other_method

  # now, you'll have these methods available to be used anywhere
  # example: mapping the 2d jsonified array returned.
  def data
    records.map do |record|
      {
        first_name: link_to(record.fname, edit_resource_path(record)),
        email:      mail_to(record.email),
        # other attributes
      }
    end
  end
end
```


#### Options

An `AjaxDatatablesRails::Base` inherited class can accept an options hash at
initialization. This provides room for flexibility when required. Example:

```ruby
class UnrespondedMessagesDatatable < AjaxDatatablesRails::Base
  # customized methods here
end

datatable = UnrespondedMessagesDatatable.new(view_context,
  { user: current_user, from: 1.month.ago }
)
```

So, now inside your class code, you can use those options like this:


```ruby
# let's see an example
def user
  @user ||= options[:user]
end

def from
  @from ||= options[:from].beginning_of_day
end

def to
  @to ||= Date.today.end_of_day
end

def get_raw_records
  user.messages.unresponded.where(received_at: from..to)
end
```


#### Generator Syntax

Also, a class that inherits from `AjaxDatatablesRails::Base` is not tied to an
existing model, module, constant or any type of class in your Rails app.
You can pass a name to your datatable class like this:


```sh
$ rails generate datatable users
# returns a users_datatable.rb file with a UsersDatatable class

$ rails generate datatable contact_messages
# returns a contact_messages_datatable.rb file with a ContactMessagesDatatable class

$ rails generate datatable UnrespondedMessages
# returns an unresponded_messages_datatable.rb file with an UnrespondedMessagesDatatable class
```

In the end, it's up to the developer which model(s), scope(s), relationship(s)
(or else) to employ inside the datatable class to retrieve records from the
database.


## Tutorial

Tutorial for Integrating `ajax-datatables-rails` on  Rails 4.

[Part-1  The-Installation](https://github.com/jbox-web/ajax-datatables-rails/wiki/Part-1----The-Installation)

[Part 2 The Datatables with ajax functionality](https://github.com/jbox-web/ajax-datatables-rails/wiki/Part-2-The-Datatables-with-ajax-functionality)

The complete project code for this tutorial series is available on [github](https://github.com/trkrameshkumar/simple_app).

Another sample project [code](https://github.com/ajahongir/ajax-datatables-rails-v-0-4-0-how-to). Its real world example.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
