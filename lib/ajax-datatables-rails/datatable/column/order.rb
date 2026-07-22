# frozen_string_literal: true

module AjaxDatatablesRails
  module Datatable
    class Column
      module Order

        def orderable?
          @view_column.fetch(:orderable, true) && orderable_field?
        end

        # A dotted source (Model.field) is only orderable if `field` is a real
        # database column; an ORDER BY against a source that points at an
        # association name or a value absent from the schema (e.g. `Model.campings`)
        # would raise. Custom fields (no dot in the source) and an explicit
        # `sort_field` override are trusted and always allowed.
        def orderable_field?
          custom_field? || @view_column.key?(:sort_field) || model.column_names.include?(field.to_s)
        end

        # Add sort_field option to allow overriding of sort field
        def sort_field
          @view_column.fetch(:sort_field, field)
        end

        def sort_query
          custom_field? ? source : "#{table.name}.#{sort_field}"
        end

        # Add option to sort null values last
        def nulls_last?
          @view_column.fetch(:nulls_last, false)
        end

      end
    end
  end
end
