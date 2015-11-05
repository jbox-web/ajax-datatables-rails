module AjaxDatatablesRails
  class Base
    extend Forwardable
    class MethodNotImplementedError < StandardError; end

    attr_reader :view, :options, :sortable_columns, :searchable_columns
    def_delegator :@view, :params, :params

    def initialize(view, options = {})
      @view = view
      @options = options
      load_paginator
    end

    def config
      @config ||= AjaxDatatablesRails.config
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
        :draw => params[:draw].to_i,
        :recordsTotal =>  get_raw_records.count(:all),
        :recordsFiltered => filter_records(get_raw_records).count(:all),
        :data => data
      }
    end

    def self.deprecated(message, caller = Kernel.caller[1])
      warning = caller + ": " + message

      if(respond_to?(:logger) && logger.present?)
        logger.warn(warning)
      else
        warn(warning)
      end
    end

    private

    def records
      @records ||= fetch_records
    end

    def fetch_records
      records = get_raw_records
      records = sort_records(records) if params[:order].present?
      records = filter_records(records) if params[:search].present?
      records = paginate_records(records) unless params[:length].present? && params[:length] == '-1'
      records
    end

    def sort_records(records)
      params[:order].values.reduce(records) do |sorted_records, item|
        condition = sort_column(item).order_condition(sort_direction(item))
        sorted_records.order(condition)
      end
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
      return records unless (params[:search].present? && params[:search][:value].present?)
      conditions = build_conditions_for(params[:search][:value])
      records = records.where(conditions) if conditions
      records
    end

    def composite_search(records)
      conditions = aggregate_query
      records = records.where(conditions) if conditions
      records
    end

    def build_conditions_for(query)
      search_for = query.split(' ')
      search_for.inject([]) do |criteria, atom|
        criteria << searchable_columns.map do |col|
          Column.from_string(col, config.db_adapter).filter_condition(atom)
        end.reduce(:or)
      end.reduce(:and)
    end

    def aggregate_query
      conditions = if params[:columns]
        searchable_columns.each_with_index.map do |column, index|
          value = params[:columns]["#{index}"][:search][:value]
          Column.from_string(column, config.db_adapter).filter_condition(value)
        end
      else []
      end

      conditions.compact.reduce(:and)
    end

    def offset
      (page - 1) * per_page
    end

    def page
      (params[:start].to_i / per_page) + 1
    end

    def per_page
      params.fetch(:length, 10).to_i
    end

    def sort_column(item)
      column = sortable_columns[sortable_displayed_columns.index(item[:column])]
      Column.from_string(column, config.db_adapter)
    end

    def sort_direction(item)
      options = %w(desc asc)
      options.include?(item[:dir]) ? item[:dir].to_sym : :asc
    end

    def sortable_displayed_columns
      @sortable_displayed_columns ||= generate_sortable_displayed_columns
    end

    def generate_sortable_displayed_columns
      @sortable_displayed_columns = []
      params[:columns].each_value do |column|
        @sortable_displayed_columns << column[:data] if column[:orderable] == 'true'
      end
      @sortable_displayed_columns
    end

    def load_paginator
      case config.paginator
      when :kaminari
        extend Extensions::Kaminari
      when :will_paginate
        extend Extensions::WillPaginate
      else
        extend Extensions::SimplePaginator
      end
      self
    end
  end
end
