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

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  if ENV.key?('GITHUB_ACTIONS')
    config.around(:each) do |ex|
      ex.run_with_retry retry: 3
    end
  end
end

require 'ajax-datatables-rails'

adapter = ENV.fetch('DB_ADAPTER', 'postgresql')

options = {
  adapter:  adapter,
  database: 'ajax_datatables_rails',
  encoding: 'utf8'
}

options = options.merge(host: '127.0.0.1', port: 5432, username: 'postgres', password: 'postgres') if adapter == 'postgresql'
options = options.merge(host: '127.0.0.1', port: 3306, username: 'root', password: 'root') if adapter == 'mysql2'
options = options.merge(username: ENV['USER'], password: ENV['USER'], database: 'xe', host: '127.0.0.1/xe') if adapter == 'oracle_enhanced'
options = options.merge(database: ':memory:') if adapter == 'sqlite3'

ActiveRecord::Base.establish_connection(options)

Dir[File.dirname(__FILE__) + '/support/**/*.rb'].sort.each { |f| require f }
