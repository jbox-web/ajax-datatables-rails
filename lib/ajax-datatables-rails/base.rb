module AjaxDatatablesRails
  class Base
    extend Forwardable
    class MethodNotImplementedError < StandardError; end

    attr_reader :view, :options, :sortable_columns, :searchable_columns
    def_delegator :@view, :params, :params

    def initialize(view, options = {})
      @view = view
      @options = options
    end

    def sortable_columns
      @sortable_columns ||= []
    end

    def searchable_columns
      @searchable_columns ||= []
    end

    def data
      fail(
        MethodNotImplementedError,
        'Please implement this method in your class.'
      )
    end

    def get_raw_records
      fail(
        MethodNotImplementedError,
        'Please implement this method in your class.'
      )
    end

    def as_json(options = {})
      {
        :sEcho => params[:sEcho].to_i,
        :iTotalRecords => get_raw_records.count,
        :iTotalDisplayRecords => filter_records(get_raw_records).count,
        :aaData => data
      }
    end

    private

    def records
      @records ||= fetch_records
    end

    def fetch_records
      records = get_raw_records
      records = sort_records(records)
      records = filter_records(records)
      records = paginate_records(records)
      records
    end

    def sort_records(records)
      records.order("#{sort_column} #{sort_direction}")
    end

    def paginate_records(records)
      fail(
        MethodNotImplementedError,
        'Please mixin a pagination extension.'
      )
    end

    def filter_records(records)
      records = simple_search(records)
      records = composite_search(records)
      records
    end

    def simple_search(records)
      return records unless params[:sSearch]
      conditions = build_conditions_for(params[:sSearch])
      records = records.where(conditions) if conditions
      records
    end

    def composite_search(records)
      conditions = aggregate_query
      records = records.where(conditions) if conditions
      records
    end

    def build_conditions_for(query)
      searchable_columns.map { |col| search_condition(col, query) }.reduce(:or)
    end

    def search_condition(column, value)
      model, column = column.split('.')
      model = model.singularize.titleize.gsub( / /, '' ).constantize
      model.arel_table[column.to_sym].matches("%#{value}%")
    end

    def aggregate_query
      conditions = searchable_columns.each_with_index.map do |column, index|
        value = params["sSearch_#{index}".to_sym]
        search_condition(column, value) unless value.blank?
      end
      conditions.compact.reduce(:and)
    end

    def offset
      (page - 1) * per_page
    end

    def page
      (params[:iDisplayStart].to_i / per_page) + 1
    end

    def per_page
      params.fetch(:iDisplayLength, 10).to_i
    end

    def sort_column
      sortable_columns[params[:iSortCol_0].to_i]
    end

    def sort_direction
      options = %w(desc asc)
      options.include?(params[:sSortDir_0]) ? params[:sSortDir_0].upcase : 'ASC'
    end
  end
end
