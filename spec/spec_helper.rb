require 'simplecov'
require 'rspec'
require 'pry'
require 'rails'
require 'active_record'

# Start Simplecov
SimpleCov.start do
  add_filter 'spec/'
end

require 'ajax-datatables-rails'

ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'

load File.dirname(__FILE__) + '/schema.rb'
load File.dirname(__FILE__) + '/test_helpers.rb'
require File.dirname(__FILE__) + '/test_models.rb'
