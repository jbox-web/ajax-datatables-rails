module AjaxDatatablesRails
  class NotImplemented < StandardError; end

  class Base
    extend Forwardable

    attr_reader :view, :options
    def_delegator :@view, :params

    def initialize(view, options = {})
      @view    = view
      @options = options
      load_orm_extension
    end

    def config
      @config ||= AjaxDatatablesRails.config
    end

    def datatable
      @datatable ||= Datatable::Datatable.new(self)
    end

    def view_columns
      fail(NotImplemented, view_columns_error_text)
    end

    def get_raw_records
      fail(NotImplemented, raw_records_error_text)
    end

    def data
      fail(NotImplemented, data_error_text)
    end

    def additional_datas
      {}
    end

    def as_json(*)
      {
        recordsTotal: records_total_count,
        recordsFiltered: records_filtered_count,
        data: sanitize(data)
      }.merge(additional_datas)
    end

    def records
      @records ||= retrieve_records
    end

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

    private

    def sanitize(data)
      data.map do |record|
        if record.is_a?(Array)
          record.map { |td| ERB::Util.html_escape(td) }
        else
          record.update(record){ |_, v| ERB::Util.html_escape(v) }
        end
      end
    end

    def retrieve_records
      records = fetch_records
      records = filter_records(records)
      records = sort_records(records)     if datatable.orderable?
      records = paginate_records(records) if datatable.paginate?
      records
    end

    def records_total_count
      get_raw_records.count(:all)
    end

    def records_filtered_count
      filter_records(get_raw_records).count(:all)
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
  end
end
