# frozen_string_literal: true

module AjaxDatatablesRails
  class Base

    class << self
      def default_db_adapter
        ::ActiveRecord::Base.configurations.configs_for(env_name: Rails.env).first.adapter.downcase.to_sym
      end
    end

    class_attribute :db_adapter, default: default_db_adapter
    class_attribute :nulls_last, default: false

    attr_reader :params, :options, :datatable

    GLOBAL_SEARCH_DELIMITER = ' '

    def initialize(params, options = {})
      @params    = params
      @options   = options
      @datatable = Datatable::Datatable.new(self)

      @connected_columns  = nil
      @searchable_columns = nil
      @search_columns     = nil
      @records            = nil
      @build_conditions   = nil
    end

    # User defined methods
    def view_columns
      raise(NotImplementedError, <<~ERROR)

        You should implement this method in your class and return an array
        of database columns based on the columns displayed in the HTML view.
        These columns should be represented in the ModelName.column_name,
        or aliased_join_table.column_name notation.
      ERROR
    end

    def get_raw_records
      raise(NotImplementedError, <<~ERROR)

        You should implement this method in your class and specify
        how records are going to be retrieved from the database.
      ERROR
    end

    def data
      raise(NotImplementedError, <<~ERROR)

        You should implement this method in your class and return an array
        of arrays, or an array of hashes, as defined in the jQuery.dataTables
        plugin documentation.
      ERROR
    end

    # ORM defined methods
    def fetch_records
      get_raw_records
    end

    def filter_records(records)
      raise(NotImplementedError)
    end

    def sort_records(records)
      raise(NotImplementedError)
    end

    def paginate_records(records)
      raise(NotImplementedError)
    end

    # User overides
    def additional_data
      {}
    end

    # JSON structure sent to jQuery DataTables
    def as_json(*)
      {
        recordsTotal:    records_total_count,
        recordsFiltered: records_filtered_count,
        data:            sanitize_data(data),
      }.merge(draw_id).merge(additional_data)
    end

    # User helper methods
    def column_id(name)
      view_columns.keys.index(name.to_sym)
    end

    def column_data(column)
      id = column_id(column)
      params.dig('columns', id.to_s, 'search', 'value')
    end

    private

    # helper methods
    def connected_columns
      @connected_columns ||= begin
        view_columns.keys.map do |field_name|
          datatable.column_by(:data, field_name.to_s)
        end.compact
      end
    end

    def searchable_columns
      @searchable_columns ||= begin
        connected_columns.select(&:searchable?)
      end
    end

    def search_columns
      @search_columns ||= begin
        searchable_columns.select(&:searched?)
      end
    end

    def sanitize_data(data)
      data.map do |record|
        if record.is_a?(Array)
          record.map { |td| ERB::Util.html_escape(td) }
        else
          record.update(record) { |_, v| ERB::Util.html_escape(v) }
        end
      end
    end

    # called from within #data
    def records
      @records ||= retrieve_records
    end

    def retrieve_records
      records = fetch_records
      records = filter_records(records)
      records = sort_records(records)     if datatable.orderable?
      records = paginate_records(records) if datatable.paginate?
      records
    end

    def records_total_count
      numeric_count fetch_records.count(:all)
    end

    def records_filtered_count
      numeric_count filter_records(fetch_records).count(:all)
    end

    def numeric_count(count)
      count.is_a?(Hash) ? count.values.size : count
    end

    def global_search_delimiter
      GLOBAL_SEARCH_DELIMITER
    end

    # See: https://datatables.net/manual/server-side#Returned-data
    def draw_id
      params[:draw].present? ? { draw: params[:draw].to_i } : {}
    end

  end
end
