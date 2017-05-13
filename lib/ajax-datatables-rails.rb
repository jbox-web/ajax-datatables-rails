module AjaxDatatablesRails
  require 'ajax-datatables-rails/version'
  require 'ajax-datatables-rails/config'
  require 'ajax-datatables-rails/base'
  require 'ajax-datatables-rails/datatable/datatable'
  require 'ajax-datatables-rails/datatable/simple_search'
  require 'ajax-datatables-rails/datatable/simple_order'
  require 'ajax-datatables-rails/datatable/column_date_filter' unless AjaxDatatablesRails.old_rails?
  require 'ajax-datatables-rails/datatable/column'
  require 'ajax-datatables-rails/orm/active_record'
end
