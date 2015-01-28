require 'pry'
require 'rails'
require 'active_record'
require 'ajax-datatables-rails'

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

load File.dirname(__FILE__) + '/schema.rb'
require File.dirname(__FILE__) + '/test_models.rb'
