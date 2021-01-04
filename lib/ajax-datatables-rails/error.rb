# frozen_string_literal: true

module AjaxDatatablesRails
  module Error
    class BaseError < StandardError; end
    class InvalidSearchColumn < BaseError; end
    class InvalidSearchCondition < BaseError; end
  end
end
