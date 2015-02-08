require 'active_support/configurable'

module AjaxDatatablesRails

  # configure AjaxDatatablesRails global settings
  #   AjaxDatatablesRails.configure do |config|
  #     config.db_adapter = :pg
  #   end
  def self.configure &block
    yield @config ||= AjaxDatatablesRails::Configuration.new
  end

  # AjaxDatatablesRails global settings
  def self.config
    @config ||= AjaxDatatablesRails::Configuration.new
  end

  class Configuration
    include ActiveSupport::Configurable

    config_accessor(:orm) { :active_record }
    config_accessor(:db_adapter) { :pg }
  end
end
