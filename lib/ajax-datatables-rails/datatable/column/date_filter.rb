# frozen_string_literal: true

module AjaxDatatablesRails
  module Datatable
    class Column
      module DateFilter

        RANGE_DELIMITER = '-'

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
          @delimiter ||= @view_column.fetch(:delimiter, RANGE_DELIMITER)
        end

        # A range value is in form '<range_start><delimiter><range_end>'
        # This returns <range_start>
        def range_start
          @range_start ||= formatted_value.split(delimiter)[0]
        end

        # A range value is in form '<range_start><delimiter><range_end>'
        # This returns <range_end>
        def range_end
          @range_end ||= formatted_value.split(delimiter)[1]
        end

        def empty_range_search?
          (formatted_value == delimiter) || (range_start.blank? && range_end.blank?)
        end

        # Do a range search
        def date_range_search
          return nil if empty_range_search?

          start_date = range_start_casted
          end_date   = range_end_casted
          # A non-blank but unparsable bound (parse_date returns nil) means the
          # filter cannot be built: skip it rather than crashing or emitting a
          # NULL-bounded BETWEEN.
          return nil if start_date.nil? || end_date.nil?

          table[field].between(DateRange.new(start_date, end_date))
        end

        private

        def range_start_casted
          range_start.blank? ? parse_date('01/01/1970') : parse_date(range_start)
        end

        def range_end_casted
          range_end.blank? ? parse_date('9999-12-31 23:59:59') : parse_date("#{range_end} 23:59:59")
        end

        def parse_date(date)
          # Zone-aware when a Time.zone is configured; the bare Time.parse is the
          # intentional fallback for apps that never set one.
          Time.zone ? Time.zone.parse(date) : Time.parse(date) # rubocop:disable Rails/TimeZone
        rescue ArgumentError, TypeError
          nil
        end

      end
    end
  end
end
