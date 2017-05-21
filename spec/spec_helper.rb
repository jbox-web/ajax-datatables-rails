require 'simplecov'
require 'rspec'
require 'database_cleaner'
require 'factory_girl'
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
  config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    FactoryGirl.find_definitions
  end

  config.after(:each) do
    AjaxDatatablesRails.configure do |c|
      c.db_adapter = ActiveRecord::Base.connection.adapter_name.downcase.to_sym
      c.orm = :active_record
    end
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
end

require 'ajax-datatables-rails'

adapter = ENV.fetch('DB_ADAPTER', 'postgresql')

options = {
  adapter:  adapter,
  database: 'ajax_datatables_rails',
  encoding: 'utf8'
}

options = options.merge(username: 'root') if adapter == 'mysql2'
options = options.merge(username: ENV['USER'], password: ENV['USER'], database: 'xe', host: '127.0.0.1/xe') if adapter == 'oracle_enhanced'
options = options.merge(database: ':memory:') if adapter == 'sqlite3'

ActiveRecord::Base.establish_connection(options)

AjaxDatatablesRails.configure do |c|
  c.db_adapter = ActiveRecord::Base.connection.adapter_name.downcase.to_sym
  c.orm = :active_record
end

load File.dirname(__FILE__) + '/support/schema.rb'
load File.dirname(__FILE__) + '/support/test_helpers.rb'
require File.dirname(__FILE__) + '/support/test_models.rb'
