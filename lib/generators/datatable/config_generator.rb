require 'rails/generators'

module Datatable
  module Generators
    class ConfigGenerator < ::Rails::Generators::Base
      source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
      desc <<DESC
Description:
  Creates an initializer file for AjaxDatatablesRails configuration at config/initializers.
DESC

      def copy_config_file
        template 'ajax_datatables_rails_config.rb', 'config/initializers/ajax_datatables_rails.rb'
      end
    end
  end
end
