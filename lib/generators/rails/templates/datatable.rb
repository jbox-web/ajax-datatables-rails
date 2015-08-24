class <%= @datatable_name %>Datatable < AjaxDatatablesRails::Base

  def view_columns
    # Declare strings in this format: ModelName.column_name
    # or in aliased_join_table.column_name format
    @view_columns ||= {}
  end

  def data
    records.map do |record|
      [
        # comma separated list of the values for each cell of a table row
        # example: record.attribute,
      ]
    end
  end

  private

  def get_raw_records
    # insert query here
  end

  # ==== Insert 'presenter'-like methods below if necessary
end
