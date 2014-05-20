module AjaxDatatablesRails
  module Extensions
    module WillPaginate

      private
      
      def paginate_records(records)
        records.paginate(:page => page, :per_page => per_page)
      end
    end
  end
end