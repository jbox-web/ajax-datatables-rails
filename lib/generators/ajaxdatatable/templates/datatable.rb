class <%= model.classify %>Datatable < AjaxDatatableRails
  model_name <%= model.classify %>
  columns # insert array of column names here
  searchable_columns #insert array of columns that will be searched
  
private

    def data
      # generate a 2-dimensional array that holds the data
    end

    def <%= model.tableize %>
      @<%= model.tableize %> ||= fetch_records
    end

    def get_raw_records
      # insert query here
    end
end
