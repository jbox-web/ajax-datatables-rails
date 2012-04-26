class FilterdatatableGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  argument :model, type: :string

  def generate_ajaxdatatable
    template 'filter.rb', File.join('app/datatables', "#{model.tableize}_filter_datatable.rb")
  end
end