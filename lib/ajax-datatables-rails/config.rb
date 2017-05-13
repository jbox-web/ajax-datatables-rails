require 'active_support/configurable'

module AjaxDatatablesRails

  # configure AjaxDatatablesRails global settings
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

  def self.rails_41?
    Rails::VERSION::MAJOR == 4 && Rails::VERSION::MINOR == 1
  end

  class Configuration
    include ActiveSupport::Configurable

    config_accessor(:orm) { :active_record }
    config_accessor(:db_adapter) { :postgresql }
  end
end
