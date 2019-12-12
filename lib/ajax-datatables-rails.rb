# frozen_string_literal: true

require 'active_support/configurable'

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
  # Configure AjaxDatatablesRails global settings
  #
  #   AjaxDatatablesRails.configure do |config|
  #     config.db_adapter = :postgresql
  #   end

  def self.configure
    yield @config ||= AjaxDatatablesRails::Configuration.new
  end

  # AjaxDatatablesRails global settings
  def self.config
    @config ||= AjaxDatatablesRails::Configuration.new
  end
end
