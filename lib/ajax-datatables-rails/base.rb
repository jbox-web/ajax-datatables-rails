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

    def datatable
      @datatable ||= Datatable::Datatable.new params, view_columns
    end

    def view_columns
      fail(NotImplemented, view_columns_error_text)
    end

    def data
      fail(NotImplemented, data_error_text)
    end

    def as_json(options = {})
      {
        draw: params[:draw].to_i,
        recordsTotal: get_raw_records.count(:all),
        recordsFiltered: filter_records(get_raw_records).count(:all),
        data: data
      }
    end

    def records
      @records ||= retrieve_records
    end

    # helper methods
    def searchable_columns
      @searchable_columns ||= begin
        connected_columns.each_with_object({}) do |(column, column_def), cols|
          cols[column] = column_def if column.searchable?
        end
      end
    end

    def search_columns
      @search_columns ||= begin
        searchable_columns.each_with_object({}) do |(column, column_def), cols|
          cols[column] = column_def if column.search.value.present?
        end
      end
    end

    def connected_columns
      @connected_columns ||= begin
        view_columns.each_with_object({}) do |(k, v), cols|
          column = datatable.column(:data, k.to_s)
          cols[column] = v[:source] if column
        end
      end
    end

    private

    def retrieve_records
      records = fetch_records
      records = filter_records(records)   #if datatable.searchable?
      records = sort_records(records)     if datatable.orderable?
      records = paginate_records(records) if datatable.paginate?
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
