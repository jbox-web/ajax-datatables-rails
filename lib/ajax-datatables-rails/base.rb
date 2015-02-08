module AjaxDatatablesRails
  class NotImplemented < StandardError; end

  class Base
    extend Forwardable

    attr_reader :view, :options, :sortable_columns, :searchable_columns
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

    def get_raw_records
      fail(NotImplemented, raw_records_error_text)
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

    def records
      @records ||= retrieve_records
    end

    # helper methods
    def searchable_columns
      searchable_indexes = params[:columns].each_value.map do |column|
                             column[:data].to_i if column[:searchable] == 'true'
                           end.compact
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
