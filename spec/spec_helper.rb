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

  config.before(:each) do
    AjaxDatatablesRails.configure do |c|
      c.db_adapter = :sqlite
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

ActiveRecord::Base.establish_connection(
  adapter:  'postgresql',
  database: 'ajax_datatables_rails'
)

load File.dirname(__FILE__) + '/support/schema.rb'
load File.dirname(__FILE__) + '/support/test_helpers.rb'
require File.dirname(__FILE__) + '/support/test_models.rb'
