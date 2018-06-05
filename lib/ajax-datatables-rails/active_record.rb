# frozen_string_literal: true

module AjaxDatatablesRails
  class ActiveRecord < AjaxDatatablesRails::Base
    include AjaxDatatablesRails::ORM::ActiveRecord
  end
end
