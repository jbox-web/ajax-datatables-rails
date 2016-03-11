require 'rails/generators'

module Rails
  module Generators
    class DatatableGenerator < ::Rails::Generators::Base
      desc 'Creates a *_datatable model in the app/datatables directory.'
      source_root File.expand_path('../templates', __FILE__)
      argument :name, type: :string

      def generate_datatable
        template 'datatable.rb', File.join(
          'app/datatables', "#{datatable_path}.rb"
        )
      end

      def datatable_name
        datatable_path.classify
      end

      private
      def datatable_path
        "#{name.underscore}_datatable"
      end

    end
  end
end