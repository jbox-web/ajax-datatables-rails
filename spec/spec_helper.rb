# frozen_string_literal: true

require 'simplecov'
require 'rspec'
require 'rspec/retry'
require 'database_cleaner'
require 'factory_bot'
require 'faker'
require 'pry'
require 'rails'
require 'active_record'
require 'action_controller'

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

# Configure ActiveRecord
adapter = ENV.fetch('DB_ADAPTER', 'postgresql')

options = {
  adapter:  adapter,
  database: 'ajax_datatables_rails',
  encoding: 'utf8',
}

options =
  case adapter
  when 'postgresql'
    options.merge(host: '127.0.0.1', port: 5432, username: 'postgres', password: 'postgres')
  when 'mysql2'
    options.merge(host: '127.0.0.1', port: 3306, username: 'root', password: 'root')
  when 'oracle_enhanced'
    options.merge(host: '127.0.0.1/xe', username: ENV['USER'], password: ENV['USER'], database: 'xe')
  when 'sqlite3'
    options.merge(database: ':memory:')
  end

ActiveRecord::Base.establish_connection(options)

# Require our gem
require 'ajax-datatables-rails'

# Load test helpers
Dir[File.dirname(__FILE__) + '/support/**/*.rb'].sort.each { |f| require f }
