# frozen_string_literal: true

Bundler.require :default, :development

Combustion.path = 'spec/dummy'
Combustion.initialize! :all
run Combustion::Application
