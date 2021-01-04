# frozen_string_literal: true

require_relative 'lib/ajax-datatables-rails/version'

Gem::Specification.new do |s|
  s.name        = 'ajax-datatables-rails'
  s.version     = AjaxDatatablesRails::VERSION::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Joel Quenneville', 'Antonio Antillon']
  s.email       = ['joel.quenneville@collegeplus.org', 'antillas21@gmail.com']
  s.homepage    = 'https://github.com/jbox-web/ajax-datatables-rails'
  s.summary     = 'A gem that simplifies using datatables and hundreds of records via ajax'
  s.description = "A wrapper around datatable's ajax methods that allow synchronization with server-side pagination in a rails app"
  s.license     = 'MIT'
  s.metadata    = {
    'homepage_uri'    => 'https://github.com/jbox-web/ajax-datatables-rails',
    'changelog_uri'   => 'https://github.com/jbox-web/ajax-datatables-rails/blob/master/CHANGELOG.md',
    'source_code_uri' => 'https://github.com/jbox-web/ajax-datatables-rails',
    'bug_tracker_uri' => 'https://github.com/jbox-web/ajax-datatables-rails/issues',
  }

  s.required_ruby_version = '>= 2.5.0'

  s.files = `git ls-files`.split("\n")

  s.add_runtime_dependency 'zeitwerk'

  s.add_development_dependency 'activerecord-oracle_enhanced-adapter'
  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_bot'
  s.add_development_dependency 'faker'
  s.add_development_dependency 'generator_spec'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'pg'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rails', '>= 5.2'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rspec-retry'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'simplecov'
end
