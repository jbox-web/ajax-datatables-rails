# frozen_string_literal: true

require 'combustion'

Combustion.path = 'spec/dummy'
Combustion.initialize! :active_record, :action_controller

require 'simplecov'
require 'rspec'
require 'rspec/retry'
require 'database_cleaner'
require 'factory_bot'
require 'faker'
require 'pry'

# Start Simplecov
SimpleCov.start do
  add_filter 'spec/'
end

# Configure RSpec
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end

  config.color = true
  config.fail_fast = false

  config.order = :random
  Kernel.srand config.seed

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before do
    DatabaseCleaner.strategy = :transaction
  end

  config.before do
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end

  # disable monkey patching
  # see: https://relishapp.com/rspec/rspec-core/v/3-8/docs/configuration/zero-monkey-patching-mode
  config.disable_monkey_patching!

  if ENV.key?('GITHUB_ACTIONS')
    config.around do |ex|
      ex.run_with_retry retry: 3
    end
  end
end

class RunningSpec
  def self.sqlite?
    ENV['DB_ADAPTER'] == 'sqlite3'
  end

  def self.oracle?
    ENV['DB_ADAPTER'] == 'oracle_enhanced'
  end

  def self.mysql?
    ENV['DB_ADAPTER'] == 'mysql2' || ENV['DB_ADAPTER'] == 'trilogy'
  end

  def self.postgresql?
    ENV['DB_ADAPTER'] == 'postgresql' || ENV['DB_ADAPTER'] == 'postgis'
  end
end

# Require our gem
require 'ajax-datatables-rails'

# Load test helpers
Dir[File.dirname(__FILE__) + '/support/**/*.rb'].sort.each { |f| require f }
