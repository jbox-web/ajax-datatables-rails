# frozen_string_literal: true

module AjaxDatatablesRails
  module Datatable
    class Column
      module Order

        def orderable?
          @view_column.fetch(:orderable, true)
        end

        # Add sort_field option to allow overriding of sort field
        def sort_field
          @view_column[:sort_field] || field
        end

        def sort_query
          custom_field? ? source : "#{table.name}.#{sort_field}"
        end

      end
    end
  end
end
