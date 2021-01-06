## To migrate from `v1.x` to `v1.3.0`

The *v1.3.0* version has some breaking changes :

* `AjaxDatatablesRails.config.db_adapter=` is removed and is configured per datatable class now. It defaults to Rails DB adapter. (fixes [#364](https://github.com/jbox-web/ajax-datatables-rails/issues/364))

This change is transparent for everyone. Just remove `AjaxDatatablesRails.config.db_adapter=` from your configuration (if exists) and it should work fine.

Now you can use AjaxDatatablesRails in multi-db environments.

* `AjaxDatatablesRails.config.nulls_last=` is removed and is configured per datatable class now (or by column). It defaults to false.

This change is easy to mitigate : add `self.nulls_last = true` in [`ApplicationDatatable`](https://github.com/jbox-web/ajax-datatables-rails#create-a-master-parent-class-easy) and remove `AjaxDatatablesRails.config.nulls_last=`

```ruby
class ApplicationDatatable < AjaxDatatablesRails::ActiveRecord
  self.nulls_last = true
  # puts commonly used methods here
end
```

* `AjaxDatatablesRails.config` is removed with no replacement

Fix the two changes above and remove any configuration file about AjaxDatatablesRails. The gem is now configless :)

## To migrate from `v0.4.x` to `v1.0.0`

The *v1.0.0* version is a **major break** from *v0.4*.

* Datatables no longer inherits from `AjaxDatatablesRails::Base` but from `AjaxDatatablesRails::ActiveRecord` (this solves [#228](https://github.com/jbox-web/ajax-datatables-rails/issues/228))
* The `view_context` is no longer injected in Datatables but only the `params` hash (see the [example](#4-setup-the-controller-action)). This will break calls to helpers methods.

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

## To migrate from `v0.3.x` to `v0.4.x`

The *v0.4* version is a **major break** from *v0.3*.

The core has been rewriten to remove dependency on [Kaminari](https://github.com/kaminari/kaminari) or [WillPaginate](https://github.com/mislav/will_paginate).

It also brings a new (more natural) way of defining columns, based on hash definitions (and not arrays) and add some filtering options for column search.

To migrate on the v0.4 you'll need to :

* update your DataTables classes to remove all the `extend` directives
* switch to hash definitions of `view_columns`
* update your views to declare your columns bindings ([See here](https://github.com/jbox-web/ajax-datatables-rails#5-wire-up-the-javascript))
