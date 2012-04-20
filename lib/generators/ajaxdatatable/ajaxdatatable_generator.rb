class AjaxdatatableGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def generate_ajaxdatatable
    template 'datatable.rb', File.join('app/datatables', "datatable.rb")
  end
end
