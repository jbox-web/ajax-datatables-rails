# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'appraisal', git: 'https://github.com/thoughtbot/appraisal.git'

gem 'combustion'
gem 'database_cleaner'
gem 'factory_bot'
gem 'faker'
gem 'generator_spec'
gem 'guard-rspec'
gem 'pry'
gem 'puma'
gem 'rake'
gem 'rspec'
gem 'rspec-retry'
gem 'rubocop'
gem 'rubocop-factory_bot'
gem 'rubocop-performance'
gem 'rubocop-rake'
gem 'rubocop-rspec'
gem 'simplecov'

# Fallback to pg if DB_ADAPTER is not set (like in dev/local environment)
# so we can still call bin/rspec
gem 'pg' if $PROGRAM_NAME == 'bin/rspec' && ENV['DB_ADAPTER'].nil?
