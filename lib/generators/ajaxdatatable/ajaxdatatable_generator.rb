class AjaxdatatableGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  argument :model, type: :string

  def generate_ajaxdatatable
    template 'datatable.rb', File.join('app/datatables', "#{model}.rb")
  end
end
