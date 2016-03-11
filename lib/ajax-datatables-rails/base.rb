module AjaxDatatablesRails
  class NotImplemented < StandardError; end

  class Base
    extend Forwardable

    attr_reader :view, :options
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
      @datatable ||= Datatable::Datatable.new self
    end

    # Must overrited methods
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
        recordsTotal: get_raw_records.count(:all),
        recordsFiltered: get_raw_records.model.from("(#{filter_records(get_raw_records).except(:limit, :offset, :order).to_sql})").count,
        data: data
      }
    end

    def records
      @records ||= retrieve_records
    end

    # helper methods
    def searchable_columns
      @searchable_columns ||= begin
        connected_columns.select &:searchable?
      end
    end

    def search_columns
      @search_columns ||= begin
        searchable_columns.select { |column| column.search.value.present? }
      end
    end

    def connected_columns
      @connected_columns ||= begin
        view_columns.keys.map do |field_name|
          datatable.column_by(:data, field_name.to_s)
        end.compact
      end
    end

    private
    # view_columns can be an Array or Hash. we have to support all these formats of defining columns
    def connect_view_columns
      # @connect_view_columns ||= begin
      #   adapted_options =
      #     case view_columns
      #     when Hash
      #     when Array
      #       cols = {}
      #       view_columns.each_with_index({}) do |index, source|
      #         cols[index.to_s] = { source: source }
      #       end
      #       cols
      #     else
      #       view_columns
      #     end
      #   ActiveSupport::HashWithIndifferentAccess.new adapted_options
      # end
    end

    def retrieve_records
      records = fetch_records
      records = filter_records(records)
      records = sort_records(records)     if datatable.orderable?
      records = paginate_records(records) if datatable.paginate?
      records
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
