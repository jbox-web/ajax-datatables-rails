# CHANGELOG

## 0.1.0
* A fresh start. Changes base class name to: `DatatablesRails`.
* Extracts pagination functions to mixable modules.
  * A user would have the option to stick to the base
    `DatatablesRails::Extensions::SimplePaginator` or replace it with
    `DatatablesRails::Extensions::Kaminari` or
    `DatatablesRails::Extensions::WillPaginate`, depending on what he/she is using to handle record pagination.
* Removes dependency to pass in a model name to the generator. This way, the developer has more flexibility to implement whatever datatable feature is required.
* Datatable constructor accepts an optional `options` hash to provide more flexibility. See [README](https://github.com/antillas21/ajax-datatables-rails/blob/master/README.md) for examples.
