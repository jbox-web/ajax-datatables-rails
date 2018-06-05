# frozen_string_literal: true

require 'active_support/configurable'

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

  class Configuration
    include ActiveSupport::Configurable

    config_accessor(:db_adapter) { :postgresql }
    config_accessor(:nulls_last) { false }
  end
end
