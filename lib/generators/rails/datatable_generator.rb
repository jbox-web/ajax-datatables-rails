require 'rails/generators'

module Rails
  module Generators
    class DatatableGenerator < ::Rails::Generators::Base
      desc 'Creates a *_datatable model in the app/datatables directory.'
      source_root File.expand_path('../templates', __FILE__)
      argument :name, :type => :string

      def generate_datatable
        file_prefix = set_filename(name)
        @datatable_name = set_datatable_name(name)
        template 'datatable.rb', File.join(
          'app/datatables', "#{file_prefix}_datatable.rb"
        )
      end

      private

      def set_filename(name)
        name.include?('_') ? name : name.to_s.underscore
      end

      def set_datatable_name(name)
        name.include?('_') ? build_name(name) : capitalize(name)
      end

      def build_name(name)
        pieces = name.split('_')
        pieces.map(&:titleize).join
      end

      def capitalize(name)
        return name if name[0] == name[0].upcase
        name.capitalize
      end
    end
  end
end