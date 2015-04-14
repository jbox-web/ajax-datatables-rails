module AjaxDatatablesRails
  class NotImplemented < StandardError; end

  class Base
    extend Forwardable

    attr_reader :view, :options, :searchable_columns
    def_delegator :@view, :params, :params

    def initialize(view, options = {})
      @view = view
      @options = options
      load_orm_extension
    end

    def config
      @config ||= AjaxDatatablesRails.config
    end

    def view_columns
      fail(NotImplemented, view_columns_error_text)
    end

    def data
      fail(NotImplemented, data_error_text)
    end

    def as_json(options = {})
      {
        :draw => params[:draw].to_i,
        :recordsTotal =>  get_raw_records.count(:all),
        :recordsFiltered => filter_records(get_raw_records).count(:all),
        :data => data
      }
    end

    def records
      @records ||= retrieve_records
    end

    # helper methods
    def searchable_columns
      searchable_indexes = params[:columns].map {|k, v| k.to_i if v[:searchable] == 'true' }.compact
      @searchable_columns ||= view_columns.values_at(*searchable_indexes)
    end

    private

    def retrieve_records
      records = fetch_records
      records = filter_records(records) if params[:search].present?
      records = sort_records(records) if params[:order].present?
      records = paginate_records(records) unless params[:length].present? && params[:length] == '-1'
      records
    end

    def get_raw_records
      fail(NotImplemented, raw_records_error_text)
    end

    # These methods represent the basic operations to perform on records
    # and should be implemented in each ORM::Extension

    def fetch_records
      fail orm_extension_error_text
    end

    def filter_records(records)
      fail orm_extension_error_text
    end

    def sort_records(records)
      fail orm_extension_error_text
    end

    def paginate_records(records)
      fail orm_extension_error_text
    end

    # Private helper methods
    def search_query_present?
      params[:search].present? && params[:search][:value].present?
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

    def load_orm_extension
      case config.orm
      when :mongoid then nil
      when :active_record then extend ORM::ActiveRecord
      else
        nil
      end
    end

    def raw_records_error_text
      return <<-eos

        You should implement this method in your class and specify
        how records are going to be retrieved from the database.
      eos
    end

    def data_error_text
      return <<-eos

        You should implement this method in your class and return an array
        of arrays, or an array of hashes, as defined in the jQuery.dataTables
        plugin documentation.
      eos
    end

    def view_columns_error_text
      return <<-eos

        You should implement this method in your class and return an array
        of database columns based on the columns displayed in the HTML view.
        These columns should be represented in the ModelName.column_name,
        or aliased_join_table.column_name notation.
      eos
    end

    def orm_extension_error_text
      return <<-eos

        This method should be overriden by an AjaxDatatablesRails::ORM::Extension.
        It defaults to AjaxDatatables::ORM::ActiveRecord.
      eos
    end
  end
end
