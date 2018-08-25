# CHANGELOG

## 1.0.0 (2018-08-28)

* Breaking change: Remove dependency on view_context [Issue #288](https://github.com/jbox-web/ajax-datatables-rails/issues/288)
* Breaking change: Replace `config.orm = :active_record` by a class : `AjaxDatatablesRails::ActiveRecord` [Fix #228](https://github.com/jbox-web/ajax-datatables-rails/issues/228)

To mitigate this 2 changes see the [migration doc](/doc/migrate.md).

## 0.4.3 (2018-06-05)

* Add: Add `:string_eq` condition on columns filter [Issue #291](https://github.com/jbox-web/ajax-datatables-rails/issues/291)

**Note :** This is the last version to support Rails 4.0.x and Rails 4.1.x

## 0.4.2 (2018-05-15)

* Fix: Integer out of range [PR #289](https://github.com/jbox-web/ajax-datatables-rails/pull/289) from [PR #284](https://github.com/jbox-web/ajax-datatables-rails/pull/284)

## 0.4.1 (2018-05-06)

* Fix: Restore behavior of #filter method [Comment](https://github.com/jbox-web/ajax-datatables-rails/commit/07795fd26849ff1b3b567f4ce967f722907a45be#comments)
* Fix: Fix erroneous offset/start behavior [PR #264](https://github.com/jbox-web/ajax-datatables-rails/pull/264)
* Fix: "orderable" option has no effect [Issue #245](https://github.com/jbox-web/ajax-datatables-rails/issues/245)
* Fix: Fix undefined method #and [PR #235](https://github.com/jbox-web/ajax-datatables-rails/pull/235)
* Add: Add "order nulls last" option [PR #79](https://github.com/jbox-web/ajax-datatables-rails/pull/279)
* Change: Rename `additional_datas` method as `additional_data` [PR #251](https://github.com/jbox-web/ajax-datatables-rails/pull/251)
* Change: Added timezone support for daterange [PR #261](https://github.com/jbox-web/ajax-datatables-rails/pull/261)
* Change: Add # frozen_string_literal: true pragma
* Various improvements in internal API

## 0.4.0 (2017-05-21)

**Warning:** this version is a **major break** from v0.3. The core has been rewriten to remove dependency on Kaminari (or WillPaginate).

It also brings a new (more natural) way of defining columns, based on hash definitions (and not arrays) and add some filtering options for column search. Take a look at the [README](https://github.com/jbox-web/ajax-datatables-rails#customize-the-generated-datatables-class) for more infos.

## 0.3.1 (2015-07-13)
* Adds `:oracle` as supported `db_adapter`. Thanks to [lutechspa](https://github.com/lutechspa) for this contribution.

## 0.3.0 (2015-01-30)
* Changes to the `sortable_columns` and `searchable_columns` syntax as it
  required us to do unnecessary guessing. New syntax is `ModelName.column_name`
  or `Namespace::ModelName.column_name`. Old syntax of `table_name.column_name`
  is still available to use, but prints a deprecation warning. Thanks to
  [M. Saiqul Haq](https://github.com/saiqulhaq) for pointing this.
* Adds support to discover from received params if a column should be really
  considered for sorting purposes. Thanks to [Zachariah Clay](https://github.com/mebezac)
  for this contribution.
* Moves paginator settings to configuration initializer.

## 0.2.1 (2014-11-26)
* Fix count method to work with select statements under Rails 4.1. Thanks to
[Jason Mitchell](https://github.com/mitchej123) for the contribution.
* Edits to `README` documentation about the `options` hash. Thanks to
[Jonathan E Hogue](https://github.com/hoguej) for pointing out that previous
documentation was confusing and didn't address its usage properly.
* Edits to `README` documentation on complex model queries inside the
`get_raw_records` method. A round of applause to [Zoltan Paulovics](https://github.com/zpaulovics)
for contributing this awesome piece of documentation. :smile:
* Adds typecast step to `search_condition` method, so now we support having
non-text columns inside the `searchable_columns` array.
* Adds support for multi-column sorting and multi-term search. Thanks to
[Zoltan Paulovics](https://github.com/zpaulovics) for contributing this feature.
* Adds optional config initializer, so we can have a base to typecast non
text-based columns and perform searches depending on the use of `:mysql2`,
`:sqlite3` or `:pg`. Thanks to [M. Saiqul Haq](https://github.com/saiqulhaq)
for contributing this feature.

## 0.2.0 (2014-06-19)
* This version works with jQuery dataTables ver. 1.10 and it's new API syntax.
* Added `legacy` branch to repo. If your project is working with jQuery
  dataTables ver. 1.9, this is the branch you need to pull, or use the last
  `0.1.x` version of this gem.

## 0.1.2 (2014-06-18)
* Fixes `where` clause being built even when search term is an empty string.
  Thanks to [e-fisher](https://github.com/e-fisher) for spotting and fixing this.

## 0.1.1 (2014-06-13)
* Fixes problem on `searchable_columns` where the corresponding model is
a composite model name, e.g. `UserData`, `BillingAddress`.
Thanks to [iruca3](https://github.com/iruca3) for the fix.

## 0.1.0 (2014-05-21)
* A fresh start. Sets base class name to: `AjaxDatatablesRails::Base`.
* Extracts pagination functions to mixable modules.
  * A user would have the option to stick to the base
    `AjaxDatatablesRails::Extensions::SimplePaginator` or replace it with
    `AjaxDatatablesRails::Extensions::Kaminari` or
    `AjaxDatatablesRails::Extensions::WillPaginate`, depending on what he/she
    is using to handle record pagination.
* Removes dependency to pass in a model name to the generator. This way,
  the developer has more flexibility to implement whatever datatable feature is
  required.
* Datatable constructor accepts an optional `options` hash to provide
  more flexibility.
  See [README](https://github.com/antillas21/ajax-datatables-rails/blob/master/README.mds#options)
  for examples.
* Sets generator inside the `Rails` namespace. To generate an
  `AjaxDatatablesRails` child class, just execute the
  generator like this: `$ rails generate datatable NAME`.

## 0.0.1 (2012-09-10)

First release!
