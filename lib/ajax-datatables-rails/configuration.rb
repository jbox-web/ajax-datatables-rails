# frozen_string_literal: true

module AjaxDatatablesRails
  class Configuration
    include ActiveSupport::Configurable

    config_accessor(:db_adapter) { :postgresql }
    config_accessor(:nulls_last) { false }
  end
end
