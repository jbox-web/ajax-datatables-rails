module AjaxDatatablesRails
  module Datatable
    module ColumnDateFilter

      def empty_range_search?
        (formated_value == delimiter) || (range_start.blank? && range_end.blank?)
      end

      # A range value is in form '<range_start><delimiter><range_end>'
      # This returns <range_start>
      def range_start
        @range_start ||= formated_value.split(delimiter)[0]
      end

      # A range value is in form '<range_start><delimiter><range_end>'
      # This returns <range_end>
      def range_end
        @range_end ||= formated_value.split(delimiter)[1]
      end

      # Do a range search
      def date_range_search
        return nil if empty_range_search?
        new_start = range_start.blank? ? DateTime.parse('01/01/1970') : DateTime.parse(range_start)
        new_end   = range_end.blank?   ? DateTime.current : DateTime.parse("#{range_end} 23:59:59")
        table[field].between(OpenStruct.new(begin: new_start, end: new_end))
      end

      private

        def non_regex_search
          if cond == :date_range
            date_range_search
          else
            super
          end
        end

    end
  end
end
