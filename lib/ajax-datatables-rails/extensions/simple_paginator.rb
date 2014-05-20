module AjaxDatatablesRails
  module Extensions
    module SimplePaginator

      private
      
      def paginate_records(records)
        records.offset(offset).limit(per_page)
      end
    end
  end
end