# frozen_string_literal: true

require 'zeitwerk'
loader = Zeitwerk::Loader.for_gem
generators = "#{__dir__}/generators"
loader.ignore(generators)
loader.inflector.inflect(
  'orm'                   => 'ORM',
  'ajax-datatables-rails' => 'AjaxDatatablesRails'
)
loader.setup

module AjaxDatatablesRails
end
