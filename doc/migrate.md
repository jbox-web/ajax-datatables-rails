## To migrate from `v0.4.x` to `v1.0.0`

1) To mitigate the first change (Datatables no longer inherits from `AjaxDatatablesRails::Base` but from `AjaxDatatablesRails::ActiveRecord`)

Create a new `ApplicationDatatable` class and make all your classes inherits from it :

```ruby
class ApplicationDatatable < AjaxDatatablesRails::ActiveRecord
end

class PostDatatable < ApplicationDatatable
end
```

**Note :** This is now in the [ProTips™](https://github.com/jbox-web/ajax-datatables-rails#protips) section of the documentation.

2) To mitigate the second change (The `view_context` is no longer injected in Datatables)

Update the `ApplicationDatatable` class :

```ruby
class ApplicationDatatable < AjaxDatatablesRails::ActiveRecord
  extend Forwardable
  attr_reader :view
  def initialize(params, opts = {})
    @view = opts[:view_context]
    super
  end
end
```

and update your controllers :

```ruby
# before
respond_to do |format|
  format.json { render json: UserDatatable.new(view_context) }
end

# after
respond_to do |format|
  format.json { render json: UserDatatable.new(params, view_context: view_context) }
end

# if you need to inject some options
respond_to do |format|
  format.json { render json: UserDatatable.new(params, view_context: view_context, my: 'options') }
end
```

This way, you can still use `def_delegators` in your datatables [as in the documentation](https://github.com/jbox-web/ajax-datatables-rails#using-view-helpers).

Note that the recommanded way is to use [Draper gem](https://github.com/drapergem/draper) to separate filtering logic from view/presentation logic [as in the documentation](https://github.com/jbox-web/ajax-datatables-rails#using-view-decorators).
