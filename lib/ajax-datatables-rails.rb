# frozen_string_literal: true

# require external dependencies
require 'zeitwerk'

# load zeitwerk
Zeitwerk::Loader.for_gem.tap do |loader|
  loader.ignore("#{__dir__}/generators")
  loader.inflector.inflect(
    'orm'                   => 'ORM',
    'ajax-datatables-rails' => 'AjaxDatatablesRails'
  )
  loader.setup
end

module AjaxDatatablesRails
end
