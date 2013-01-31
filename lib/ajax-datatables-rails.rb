# require 'rails'

class AjaxDatatablesRails
  
  class MethodError < StandardError; end

  VERSION = '0.0.1'
    
  attr_reader :columns, :model_name, :searchable_columns

  def initialize(view)
    @view = view
  end

  def method_missing(meth, *args, &block)
    @view.send(meth, *args, &block)
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: @model_name.count,
      iTotalDisplayRecords: filtered_record_count,
      aaData: data
    }
  end

private

  def data
    raise MethodError, "The method `data' is not defined."
  end

  def get_raw_records
    raise MethodError, "The method `get_raw_records' is not defined."
  end

  def filtered_record_count
    search_records(get_raw_records).count
  end
  
  def fetch_records
    search_records(sort_records(paginate_records(get_raw_records)))
  end

  def paginate_records(records)
    records.offset((page - 1) * per_page).limit(per_page)
  end

  def sort_records(records)
    records.order(sort_order)
  end

  def search_records(records)
    if params[:sSearch].present?
      query = @searchable_columns.map do |column|
        "#{column} LIKE :search"
      end.join(" OR ")
      records = records.where(query, search: "%#{params[:sSearch]}%")
    end
    return records
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end
  
  def sort_order
    (0..(params[:iSortingCols].to_i - 1)).map do |index|
      "#{sort_column index} #{sort_direction index}"
    end
  end
  
  def sort_column index
    @columns[params["iSortCol_#{index}".to_sym].to_i]
  end

  def sort_direction index
    params["iSortDir_#{index}".to_sym] == "desc" ? "DESC" : "ASC"
  end
end
