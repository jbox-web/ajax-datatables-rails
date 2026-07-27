# ajax-datatables-rails

[![GitHub license](https://img.shields.io/github/license/jbox-web/ajax-datatables-rails.svg)](https://github.com/jbox-web/ajax-datatables-rails/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/ajax-datatables-rails.svg)](https://rubygems.org/gems/ajax-datatables-rails)
[![Gem](https://img.shields.io/gem/dtv/ajax-datatables-rails.svg)](https://rubygems.org/gems/ajax-datatables-rails)
[![CI](https://github.com/jbox-web/ajax-datatables-rails/workflows/CI/badge.svg)](https://github.com/jbox-web/ajax-datatables-rails/actions)

**Important : This gem implements the [server-side processing protocol](https://datatables.net/manual/server-side) introduced in DataTables 1.10.
It works with any DataTables version speaking that protocol (1.10.x and 2.x).**

It's tested against :

* Rails: 7.1 / 7.2 / 8.0 / 8.1
* Ruby: 3.1 / 3.2 / 3.3 / 3.4 / 4.0 (Rails 8.0 and 8.1 require Ruby >= 3.2)
* Databases: MySQL 8 / SQLite3 / Postgresql 16 / Oracle Free 23
* Adapters: sqlite / mysql2 / postgres / postgis / oracle

`trilogy` and `sqlserver` are implemented (type casting and `NULLS LAST` ordering) but are not currently exercised in CI.

## Description

> [DataTables](https://datatables.net/) is a nifty jQuery plugin that adds the ability to paginate, sort, and search your html tables.
> When dealing with large tables (more than a couple of hundred rows) however, we run into performance issues.
> These can be fixed by using server-side pagination, but this breaks some DataTables functionality.
>
> `ajax-datatables-rails` is a wrapper around DataTables ajax methods that allow synchronization with server-side pagination in a Rails app.
> It was inspired by this [Railscast](http://railscasts.com/episodes/340-datatables).
> I needed to implement a similar solution in a couple projects I was working on, so I extracted a solution into a gem.
>
> Joel Quenneville (original author)
>
> I needed a good gem to manage a lot of DataTables so I chose this one :)
>
> Nicolas Rodriguez (current maintainer)

The final goal of this gem is to **generate a JSON** content that will be given to jQuery DataTables.
All the datatable customizations (header, tr, td, css classes, width, height, buttons, etc...) **must** take place in the [javascript definition](#5-wire-up-the-javascript) of the datatable.
jQuery DataTables is a very powerful tool with a lot of customizations available. Take the time to [read the doc](https://datatables.net/reference/option/).

You'll find a sample project with real world examples here : https://github.com/jbox-web/ajax-datatables-rails-sample-project

This gem handles **only the server side**. For the client side, its companion gem
[datatables-factory](https://github.com/jbox-web/datatables-factory) builds the HTML table and the
javascript for you ([see below](#companion-gem-datatables-factory)).


## Installation

Add these lines to your application's Gemfile:

```ruby
gem 'ajax-datatables-rails'
```

And then execute:

```sh
$ bundle install
```

We assume here that you have already installed [jQuery DataTables](https://datatables.net/).

You can install jQuery DataTables :

* with `importmap-rails` (`bin/importmap pin datatables.net-dt`), the Rails 7+ default
* with `jsbundling-rails` (`yarn add datatables.net-dt`)
* by adding the assets manually (in `vendor/assets`)
* with the legacy [Rails webpacker gem](https://github.com/rails/webpacker) (see [here](/doc/webpack.md) for more infos)

Migrating from an older version of the gem ? See [the migration guide](/doc/migrate.md).


## Note

`AjaxDatatablesRails` only supports `ActiveRecord` as ORM for performing database queries.

The `AjaxDatatablesRails::ORM` namespace exists so other backends (`Sequel`, `Mongoid`...) could be plugged in,
but none is implemented and none is currently being worked on.

If you'd be interested in contributing to speed development, please [open an issue](https://github.com/jbox-web/ajax-datatables-rails/issues/new) and get in touch.


## Quick start (in 5 steps)

The following examples assume that we are setting up `ajax-datatables-rails` for an index page of users from a `User` model,
and that we are using Postgresql as our db, because you **should be using it**. (It also works with other DB, [see below](#change-the-db-adapter-for-a-datatable-class))

The goal is to render a users table and display : `id`, `first name`, `last name`, `email`, and `bio` for each user.

Something like this:

|ID |First Name|Last Name|Email                 |Brief Bio|
|---|----------|---------|----------------------|---------|
| 1 |John      |Doe      |john.doe@example.net  |Is your default user everywhere|
| 2 |Jane      |Doe      |jane.doe@example.net  |Is John's wife|
| 3 |James     |Doe      |james.doe@example.net |Is John's brother and best friend|

Here the steps we're going through :

1. [Generate the datatable class](#1-generate-the-datatable-class)
2. [Build the View](#2-build-the-view)
3. [Customize the generated Datatables class](#3-customize-the-generated-datatables-class)
4. [Setup the Controller action](#4-setup-the-controller-action)
5. [Wire up the Javascript](#5-wire-up-the-javascript)

### 1) Generate the datatable class

Run the following command:

```sh
$ rails generate datatable User
```

This will generate a file named `user_datatable.rb` in `app/datatables`.
Open the file and customize in the functions as directed by the comments.

Take a look [here](#generator-syntax) for an explanation about the generator syntax.


### 2) Build the View

You should always start by the single source of truth, which is your html view.

* Set up an html `<table>` with a `<thead>` and `<tbody>`
* Add in your table headers if desired
* Don't add any rows to the body of the table, DataTables does this automatically
* Add a data attribute to the `<table>` tag with the url of the JSON feed, in our case is the `users_path` as we're pointing to the `UsersController#index` action


```html
<table id="users-datatable" data-source="<%= users_path(format: :json) %>">
  <thead>
    <tr>
      <th>ID</th>
      <th>First Name</th>
      <th>Last Name</th>
      <th>Email</th>
      <th>Brief Bio</th>
    </tr>
  </thead>
  <tbody>
  </tbody>
</table>
```


### 3) Customize the generated Datatables class

#### a. Declare columns mapping

First we need to declare in `view_columns` the list of the model(s) columns mapped to the data we need to present.
In this case: `id`, `first_name`, `last_name`, `email` and `bio`.

This gives us:

```ruby
def view_columns
  @view_columns ||= {
    id:         { source: "User.id" },
    first_name: { source: "User.first_name", cond: :like, searchable: true, orderable: true },
    last_name:  { source: "User.last_name",  cond: :like, nulls_last: true },
    email:      { source: "User.email" },
    bio:        { source: "User.bio" },
  }
end
```

**Notes :** by default `orderable` and `searchable` are true and `cond` is `:like`.

`cond` can be :

* `:like`, `:start_with`, `:end_with`, `:string_eq`, `:string_in` for string or full text search
* `:eq`, `:not_eq`, `:lt`, `:gt`, `:lteq`, `:gteq`, `:in` for numeric
* `:date_range` for date range
* `:null_value` for nil field
* `Proc` for whatever (see [here](https://github.com/jbox-web/ajax-datatables-rails-sample-project/blob/master/app/datatables/city_datatable.rb) for real example)

Any other value raises `AjaxDatatablesRails::Error::InvalidSearchCondition`.

**About the numeric conditions :** the search value must be an integer that fits the column
(the gem checks the column byte size to avoid a Postgresql *value out of range* error).
A non-integer or out-of-range value produces an always-false condition instead of a SQL error.

**About `:null_value` :** the search value drives the direction of the test. The special value
`!NULL` searches for *non-null* rows (`WHERE col IS NOT NULL`), anything else searches for
null rows (`WHERE col IS NULL`).

**About `Proc` :** the lambda receives the `Column` object and the (formatted) search value,
and must return an Arel node :

```ruby
def view_columns
  @view_columns ||= {
    population: { source: 'City.population', cond: ->(column, value) { column.table[column.field].gt(value.to_i) } },
  }
end
```

**Silent fallbacks :** a column whose `source` is a `Model.field` pair is only searchable if
`field` is a real database column, and only orderable if `field` is a real database column or
an explicit `sort_field` is given. A `source` pointing at an association name (e.g. `User.posts`)
would otherwise generate an invalid `WHERE` / `ORDER BY` — such a column is silently dropped from
filtering and sorting rather than raising. If a column mysteriously refuses to sort or search,
check that its `source` names a column and not an association.

The `nulls_last` param allows for nulls to be ordered last. You can configure it by column, like above, or by datatable class :

```ruby
class MyDatatable < AjaxDatatablesRails::ActiveRecord
  self.nulls_last = true

  # ... other methods (view_columns, data...)
end
```

The `sort_field` param lets you order on a different column than the one displayed (e.g. sort a computed/aliased column by an underlying real column) :

```ruby
class MyDatatable < AjaxDatatablesRails::ActiveRecord
  def view_columns
    @view_columns ||= {
      full_name: { source: "User.last_name", sort_field: "last_name" },
    }
  end
end
```

The `use_regex` param (default `true`) disables regex search for a column. This is useful when DataTables multi-select filters auto-enable regex search but the column is a numeric/primary key that the DB cannot compare with a regex operator (use it together with `cond: :in`) :

```ruby
class MyDatatable < AjaxDatatablesRails::ActiveRecord
  def view_columns
    @view_columns ||= {
      post_id: { source: "User.post_id", cond: :in, use_regex: false },
    }
  end
end
```

See [here](#columns-syntax) to get more details about columns definitions and how to play with associated models.

You can customize or sanitize the search value passed to the DB by using the `:formatter` option with a lambda :

```ruby
def view_columns
  @view_columns ||= {
    id:         { source: "User.id" },
    first_name: { source: "User.first_name" },
    last_name:  { source: "User.last_name" },
    email:      { source: "User.email", formatter: -> (o) { o.upcase } },
    bio:        { source: "User.bio" },
  }
end
```

The object passed to the lambda is the search value.

#### b. Map data

Then we need to map the records retrieved by the `get_raw_records` method to the real values we want to display :

```ruby
def data
  records.map do |record|
    {
      id:         record.id,
      first_name: record.first_name,
      last_name:  record.last_name,
      email:      record.email,
      bio:        record.bio,
      DT_RowId:   record.id, # This will automagically set the id attribute on the corresponding <tr> in the datatable
    }
  end
end
```

**Deprecated:** You can either use the v0.3 Array style for your columns :

This method builds a 2d array that is used by datatables to construct the html
table. Insert the values you want on each column.

```ruby
def data
  records.map do |record|
    [
      record.id,
      record.first_name,
      record.last_name,
      record.email,
      record.bio
    ]
  end
end
```

The drawback of this method is that you can't pass the `DT_RowId` so it's tricky to set the id attribute on the corresponding `<tr>` in the datatable (need to be done on JS side).

[See here](#using-view-helpers) if you need to use view helpers like `link_to`, `mail_to`, etc...

**HTML escaping :** every leaf value returned by `data` is run through `ERB::Util.html_escape`
before being serialized. Markup you generate on purpose (with `link_to`, a decorator...) is
already `html_safe` and passes through untouched; a raw `String` containing `<` is escaped.
Nested `Hash` / `Array` values are traversed, not stringified, so DataTables row properties like
`DT_RowAttr` and `DT_RowData` (which are objects) survive :

```ruby
def data
  records.map do |record|
    {
      id:         record.id,
      DT_RowId:   record.id,
      DT_RowData: { url: user_path(record) }, # kept as a JSON object, values escaped
    }
  end
end
```

#### c. Get Raw Records

This is where your query goes.

```ruby
def get_raw_records
  User.all
end
```

Obviously, you can construct your query as required for the use case the datatable is used.

Example:

```ruby
def get_raw_records
  User.active.with_recent_messages
end
```

You can put any logic in `get_raw_records` [based on any parameters you inject](#pass-options-to-the-datatable-class) in the `Datatable` object.

**IMPORTANT :** Because the result of this method will be chained to `ActiveRecord` methods for sorting, filtering and pagination,
make sure to return an `ActiveRecord::Relation` object.

#### d. Additional data

You can inject other key/value pairs in the rendered JSON by defining the `#additional_data` method :

```ruby
def additional_data
  {
    foo: 'bar'
  }
end
```

Very useful with [datatables-factory](#companion-gem-datatables-factory) (or [yadcf](https://github.com/vedmack/yadcf)) to provide values for dropdown filters.


### 4) Setup the Controller action

Set the controller to respond to JSON

```ruby
def index
  respond_to do |format|
    format.html
    format.json { render json: UserDatatable.new(params) }
  end
end
```

Don't forget to make sure the proper route has been added to `config/routes.rb`.

[See here](#pass-options-to-the-datatable-class) if you need to inject params in the `UserDatatable`.

**Note :** If you have more than **2** datatables in your application, don't forget to read [this](#use-http-post-method-medium).

### 5) Wire up the Javascript

Finally, the javascript to tie this all together. In the appropriate `js` file:

```javascript
// users.js

jQuery(document).ready(function() {
  $('#users-datatable').dataTable({
    "processing": true,
    "serverSide": true,
    "ajax": {
      "url": $('#users-datatable').data('source')
    },
    "pagingType": "full_numbers",
    "columns": [
      {"data": "id"},
      {"data": "first_name"},
      {"data": "last_name"},
      {"data": "email"},
      {"data": "bio"}
    ]
    // pagingType is optional, if you want full pagination controls.
    // Check dataTables documentation to learn more about
    // available options.
  });
});
```

or, if you're using CoffeeScript:

```coffeescript
# users.coffee

$ ->
  $('#users-datatable').dataTable
    processing: true
    serverSide: true
    ajax:
      url: $('#users-datatable').data('source')
    pagingType: 'full_numbers'
    columns: [
      {data: 'id'}
      {data: 'first_name'}
      {data: 'last_name'}
      {data: 'email'}
      {data: 'bio'}
    ]
    # pagingType is optional, if you want full pagination controls.
    # Check dataTables documentation to learn more about
    # available options.
```

## Advanced usage

### Companion gem: datatables-factory

Everything described in [step 2](#2-build-the-view) and [step 5](#5-wire-up-the-javascript) — writing the
`<table>` markup by hand, then the matching javascript column definitions — is exactly what
[datatables-factory](https://github.com/jbox-web/datatables-factory) automates.
It is a Rails engine + javascript library, maintained by the same author, designed to be used on the
client side while `ajax-datatables-rails` serves the JSON.

It brings :

* AJAX-powered data loading
* filters : text, select, multi-select, range and **date range** (the front-end counterpart of the [`:date_range` cond](#daterange-search))
* checkbox selection with a "select all" toggle
* context menus for row actions
* column visibility toggles and CSV export buttons
* configurable HTTP method (`POST` or `QUERY`), which pairs with the [POST setup](#use-http-post-method-medium) below
* touch device support and debug logging

Installation, in the `Gemfile` :

```ruby
gem 'datatables-factory'
```

and in `package.json` :

```json
{
  "dependencies": {
    "@jbox-web/datatables-factory": "^1.0.0"
  }
}
```

The view then declares the table and its filters in Ruby, instead of raw HTML :

```erb
<% dt = bootstrap_datatables_for(:users, source: users_path) do |dt| %>
  <% dt.head_for :name, label: 'Name', sortable: true %>
  <% dt.search_form do |f| %>
    <%= f.text_field :name %>
  <% end %>
<% end %>
```

Dropdown / multi-select filters need their possible values : feed them from the datatable class with
[`additional_data`](#d-additional-data).

See the [datatables-factory README](https://github.com/jbox-web/datatables-factory) for the javascript
class definition and the `DatatableBase.load_datatables()` initialization.

### Using view helpers

Sometimes you'll need to use view helper methods like `link_to`, `mail_to`,
`edit_user_path`, `check_box_tag` and so on in the returned JSON representation returned by the [`data`](#b-map-data) method.

To have these methods available to be used, this is the way to go:

```ruby
class UserDatatable < AjaxDatatablesRails::ActiveRecord
  extend Forwardable

  # either define them one-by-one
  def_delegator :@view, :check_box_tag
  def_delegator :@view, :link_to
  def_delegator :@view, :mail_to
  def_delegator :@view, :edit_user_path

  # or define them in one pass
  def_delegators :@view, :check_box_tag, :link_to, :mail_to, :edit_user_path

  # ... other methods (view_columns, get_raw_records...)

  def initialize(params, opts = {})
    @view = opts[:view_context]
    super
  end

  # now, you'll have these methods available to be used anywhere
  def data
    records.map do |record|
      {
        id:         check_box_tag('users[]', record.id),
        first_name: link_to(record.first_name, edit_user_path(record)),
        last_name:  record.last_name,
        email:      mail_to(record.email),
        bio:        record.bio,
        DT_RowId:   record.id,
      }
    end
  end
end

# and in your controller:
def index
  respond_to do |format|
    format.html
    format.json { render json: UserDatatable.new(params, view_context: view_context) }
  end
end
```

### Using view decorators

If you want to keep things tidy in the data mapping method, you could use
[Draper](https://github.com/drapergem/draper) to define column mappings like below.

**Note :** This is the recommanded way as you don't need to inject the `view_context` in the Datatable object to access helpers methods.
It also helps in separating view/presentation logic from filtering logic (the only one that really matters in a datatable class).

Example :

```ruby
class UserDatatable < AjaxDatatablesRails::ActiveRecord
  ...
  def data
    records.map do |record|
      {
        id:         record.decorate.check_box,
        first_name: record.decorate.link_to,
        last_name:  record.decorate.last_name,
        email:      record.decorate.email,
        bio:        record.decorate.bio,
        DT_RowId:   record.id,
      }
    end
  end
  ...
end

class UserDecorator < ApplicationDecorator
  delegate :last_name, :bio

  def check_box
    h.check_box_tag 'users[]', object.id
  end

  def link_to
    h.link_to object.first_name, h.edit_user_path(object)
  end

  def email
    h.mail_to object.email
  end

  # Just an example of a complex method you can add to you decorator
  # To render it in a datatable just add a column 'dt_actions' in
  # 'view_columns' and 'data' methods and call record.decorate.dt_actions
  def dt_actions
    links = []
    links << h.link_to 'Edit',   h.edit_user_path(object) if h.policy(object).update?
    links << h.link_to 'Delete', h.user_path(object), method: :delete, remote: true if h.policy(object).destroy?
    h.safe_join(links, '')
  end
end
```

### Pass options to the datatable class

An `AjaxDatatablesRails::ActiveRecord` inherited class can accept an options hash at initialization. This provides room for flexibility when required.

Example:

```ruby
# In the controller
def index
  respond_to do |format|
    format.html
    format.json { render json: UserDatatable.new(params, user: current_user, from: 1.month.ago) }
  end
end

# The datatable class
class UnrespondedMessagesDatatable < AjaxDatatablesRails::ActiveRecord

  # ... other methods (view_columns, data...)

  def user
    @user ||= options[:user]
  end

  def from
    @from ||= options[:from].beginning_of_day
  end

  def to
    @to ||= Date.today.end_of_day
  end

  # We can now customize the get_raw_records method
  # with the options we've injected
  def get_raw_records
    user.messages.unresponded.where(received_at: from..to)
  end

end
```

### Change the DB adapter for a datatable class

If you have models from different databases you can set the `db_adapter` on the datatable class :

```ruby
class MySharedModelDatatable < AjaxDatatablesRails::ActiveRecord
  self.db_adapter = :oracle_enhanced

  # ... other methods (view_columns, data...)

  def get_raw_records
    AnimalsRecord.connected_to(role: :reading) do
      Dog.all
    end
  end
end
```

### How the global search box works

The single search box at the top of the table is handled apart from the per-column search fields :

* its value is split on spaces, each word being one search atom
* an atom matches if **any** searchable column matches it (`OR`)
* **all** atoms must match (`AND`) — the classic "all words present, anywhere" behaviour
* columns that already carry their own per-column search value are excluded from the global search
* each atom goes through the column's own `cond` / `formatter`, so a `:like` column is matched with `LIKE`, an `:eq` column with `=`, etc...

The final `WHERE` clause is therefore `(per-column searches) AND (global search)`, each part being optional.

### Grouped queries

`get_raw_records` may return a grouped relation. In that case ActiveRecord's `count` returns a Hash
keyed by group, and the gem reports the **number of groups** in `recordsTotal` / `recordsFiltered`
(instead of choking on a Hash) :

```ruby
def get_raw_records
  User.group(:role)
end
```

### Reading the request params

Two helpers are available in your datatable class to inspect the incoming request :

```ruby
# index of a column in view_columns (the position DataTables uses)
column_id(:first_name) # => 1

# per-column search value sent by DataTables for that column
column_data(:first_name) # => 'John'
```

Useful when `get_raw_records` needs to branch on what the user is filtering on.

### Columns syntax

You can mix several model in the same datatable.

Suppose we have the following models: `User`, `PurchaseOrder`,
`Purchase::LineItem` and we need to have several columns from those models
available in our datatable to search and sort by.

```ruby
# we use the ModelName.column_name notation to declare our columns

def view_columns
  @view_columns ||= {
    first_name:       { source: 'User.first_name' },
    last_name:        { source: 'User.last_name' },
    order_number:     { source: 'PurchaseOrder.number' },
    order_created_at: { source: 'PurchaseOrder.created_at' },
    quantity:         { source: 'Purchase::LineItem.quantity' },
    unit_price:       { source: 'Purchase::LineItem.unit_price' },
    item_total:       { source: 'Purchase::LineItem.item_total' }
  }
end
```

### Associated and nested models

The previous example has only one single model. But what about if you have
some associated nested models and in a report you want to show fields from
these tables.

Take an example that has an `Event, Course, CourseType, Allocation, Teacher,
Contact, Competency and CompetencyType` models. We want to have a datatables
report which has the following column:

```ruby
'course_types.name'
'courses.name'
'contacts.full_name'
'competency_types.name'
'events.title'
'events.event_start'
'events.event_end'
'events.status'
```

We want to sort and search on all columns of the list.
The related definition would be :

```ruby
def view_columns
  @view_columns ||= {
    course_type:     { source: 'CourseType.name' },
    course_name:     { source: 'Course.name' },
    contact_name:    { source: 'Contact.full_name' },
    competency_type: { source: 'CompetencyType.name' },
    event_title:     { source: 'Event.title' },
    event_start:     { source: 'Event.event_start' },
    event_end:       { source: 'Event.event_end' },
    event_status:    { source: 'Event.status' },
  }
end

def get_raw_records
  Event.joins(
    { course: :course_type },
    { allocations: {
      teacher: [:contact, { competencies: :competency_type }]
    }
  }).distinct
end
```

**Some comments for the above code :**

1. In the `get_raw_records` method we have quite a complex query having one to
many and many to many associations using the joins ActiveRecord method.
The joins will generate INNER JOIN relations in the SQL query. In this case,
we do not include all event in the report if we have events which is not
associated with any model record from the relation.

2. To have all event records in the list we should use the `.includes` method,
which generate LEFT OUTER JOIN relation of the SQL query.

**IMPORTANT :**

Make sure to append `.references(:related_model)` with any
associated model. That forces the eager loading of all the associated models
by one SQL query, and the search condition for any column works fine.
Otherwise the `:recordsFiltered => filter_records(get_raw_records).count(:all)`
will generate 2 SQL queries (one for the Event model, and then another for the
associated tables). The `:recordsFiltered => filter_records(get_raw_records).count(:all)`
will use only the first one to return from the ActiveRecord::Relation object
in `get_raw_records` and you will get an error message of **Unknown column
'yourtable.yourfield' in 'where clause'** in case the search field value
is not empty.

So the query using the `.includes()` method is:

```ruby
def get_raw_records
  Event.includes(
    { course: :course_type },
    { allocations: {
      teacher: [:contact, { competencies: :competency_type }]
    }
  }).references(:course).distinct
end
```

### Default scope

See [DefaultScope is evil](https://rails-bestpractices.com/posts/2013/06/15/default_scope-is-evil/) and [#223](https://github.com/jbox-web/ajax-datatables-rails/issues/223) and [#233](https://github.com/jbox-web/ajax-datatables-rails/issues/233).

### DateRange search

This feature works with [datatables-factory](#companion-gem-datatables-factory), which provides a
ready-made date range filter (or with [yadcf](https://github.com/vedmack/yadcf)).

To enable the date range search, for example `created_at` :

* add a `created_at` `<th>` in your html
* declare your column in `view_columns` : `created_at: { source: 'Post.created_at', cond: :date_range, delimiter: '-yadcf_delim-' }`
* add it in `data` : `created_at: record.decorate.created_at`
* setup the front-end filter to send a range for `created_at`

The `delimiter` option must match what the front-end sends : the value received is split in two
around it (`<range_start><delimiter><range_end>`). It defaults to `-`, and `-yadcf_delim-` is what
yadcf uses. An empty bound falls back to `01/01/1970` (start) or `9999-12-31 23:59:59` (end), and an
unparsable bound simply skips the filter instead of raising.

### Generator Syntax

Also, a class that inherits from `AjaxDatatablesRails::ActiveRecord` is not tied to an
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

## Tests

Datatables can be tested with Capybara provided you don't use Webrick during integration tests.

Long story short and as a rule of thumb : use the same webserver everywhere (dev, prod, staging, test, etc...).

If you use Puma (the Rails default webserver), use Puma everywhere, even in CI/test environment. The same goes for Thin.

You will avoid the usual story : it works in dev but not in test environment...

If you want to test datatables with a lot of data you might need this kind of tricks : https://robots.thoughtbot.com/automatically-wait-for-ajax-with-capybara. (thanks CharlieIGG)

## ProTips™

### Create a master parent class (Easy)

In the same spirit of Rails `ApplicationController` and `ApplicationRecord`, you can create an `ApplicationDatatable` class (in `app/datatables/application_datatable.rb`)
that will be inherited from other classes :

```ruby
class ApplicationDatatable < AjaxDatatablesRails::ActiveRecord
  # puts commonly used methods here
end

class PostDatatable < ApplicationDatatable
end
```

This way it will be easier to DRY you datatables.

### Speedup JSON rendering (Easy)

Install [yajl-ruby](https://github.com/brianmario/yajl-ruby), basically :

```ruby
gem 'yajl-ruby', require: 'yajl'
```

then

```sh
$ bundle install
```

That's all :) ([Automatically prefer Yajl or JSON backend over Yaml, if available](https://github.com/rails/rails/commit/63bb955a99eb46e257655c93dd64e86ebbf05651))

### Use HTTP `POST` method (Medium)

Use HTTP `POST` method to avoid `414 Request-URI Too Large` error. See : [#278](https://github.com/jbox-web/ajax-datatables-rails/issues/278) and [#308](https://github.com/jbox-web/ajax-datatables-rails/issues/308#issuecomment-424897335).

You can easily define a route concern in `config/routes.rb` and reuse it when you need it :

```ruby
Rails.application.routes.draw do
  concern :with_datatable do
    post 'datatable', on: :collection
  end

  resources :posts, concerns: [:with_datatable]
  resources :users, concerns: [:with_datatable]
end
```

then in your controllers :

```ruby
# PostsController
  def index
  end

  def datatable
    render json: PostDatatable.new(params)
  end

# UsersController
  def index
  end

  def datatable
    render json: UserDatatable.new(params)
  end
```

then in your views :

```html
# posts/index.html.erb
<table id="posts-datatable" data-source="<%= datatable_posts_path(format: :json) %>">

# users/index.html.erb
<table id="users-datatable" data-source="<%= datatable_users_path(format: :json) %>">
```

then in your JS :

```javascript
// send params in form data
$('#posts-datatable').dataTable({
  "ajax": {
    "url": $('#posts-datatable').data('source'),
    "type": "POST"
  }
  // ...others options, see [here](#5-wire-up-the-javascript)
});

// send params as json data
$('#users-datatable').dataTable({
  "ajax": {
    "url": $('#users-datatable').data('source'),
    "contentType": "application/json",
    "type": "POST",
    "data": function(d) { return JSON.stringify(d); }
  }
  // ...others options, see [here](#5-wire-up-the-javascript)
});
```

or in CoffeeScript :

```coffee
# send params in form data
$ ->
  $('#posts-datatable').dataTable
    ajax:
      url: $('#posts-datatable').data('source')
      type: 'POST'
    # ...others options, see [here](#5-wire-up-the-javascript)

# send params as json data
$ ->
  $('#users-datatable').dataTable
    ajax:
      url: $('#users-datatable').data('source')
      contentType: 'application/json'
      type: 'POST'
      data: (d) ->
        JSON.stringify d
    # ...others options, see [here](#5-wire-up-the-javascript)
```

### Create indices for Postgresql (Expert)

In order to speed up the `ILIKE` queries that are executed when using the default configuration, you might want to consider adding some indices.
For postgresql, you are advised to use the [gin/gist index type](http://www.postgresql.org/docs/current/interactive/pgtrgm.html).
This makes it necessary to enable the postgrsql extension `pg_trgm`. Double check that you have this extension installed before trying to enable it.
A migration for enabling the extension and creating the indices could look like this:

```ruby
def change
  enable_extension :pg_trgm
  TEXT_SEARCH_ATTRIBUTES = ['your', 'attributes']
  TABLE = 'your_table'

  TEXT_SEARCH_ATTRIBUTES.each do |attr|
    reversible do |dir|
      dir.up do
        execute "CREATE INDEX #{TABLE}_#{attr}_gin ON #{TABLE} USING gin(#{attr} gin_trgm_ops)"
      end

      dir.down do
        remove_index TABLE.to_sym, name: "#{TABLE}_#{attr}_gin"
      end
    end
  end
end
```

## Tutorial

Filtering by JSONB column values : [#277](https://github.com/jbox-web/ajax-datatables-rails/issues/277#issuecomment-366526373)

Use [has_scope](https://github.com/plataformatec/has_scope) gem with `ajax-datatables-rails` : [#280](https://github.com/jbox-web/ajax-datatables-rails/issues/280)

Use [Datatable orthogonal data](https://datatables.net/manual/data/orthogonal-data) : see [#269](https://github.com/jbox-web/ajax-datatables-rails/issues/269#issuecomment-387940478)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
