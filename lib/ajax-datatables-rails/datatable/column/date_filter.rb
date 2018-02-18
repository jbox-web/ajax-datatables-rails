# frozen_string_literal: true

module AjaxDatatablesRails
  module Datatable
    class Column
      module DateFilter

        class DateRange
          attr_reader :begin, :end

          def initialize(date_start, date_end)
            @begin = date_start
            @end   = date_end
          end

          def exclude_end?
            false
          end
        end

        # Add delimiter option to handle range search
        def delimiter
          @view_column[:delimiter] || '-'
        end

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
          table[field].between(DateRange.new(range_start_casted, range_end_casted))
        end

        private

        def non_regex_search
          if cond == :date_range
            date_range_search
          else
            super
          end
        end

        def range_start_casted
          range_start.blank? ? parse_date('01/01/1970') : parse_date(range_start)
        end

        def range_end_casted
          range_end.blank? ? Time.current : parse_date("#{range_end} 23:59:59")
        end

        def parse_date(date)
          if Time.zone
            Time.zone.parse(date)
          else
            Time.parse(date)
          end
        end

      end
    end
  end
end
