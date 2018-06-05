# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'ajax-datatables-rails/version'

Gem::Specification.new do |s|
  s.name        = 'ajax-datatables-rails'
  s.version     = AjaxDatatablesRails::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Joel Quenneville', 'Antonio Antillon']
  s.email       = ['joel.quenneville@collegeplus.org', 'antillas21@gmail.com']
  s.homepage    = 'https://github.com/jbox-web/ajax-datatables-rails'
  s.summary     = 'A gem that simplifies using datatables and hundreds of records via ajax'
  s.description = "A wrapper around datatable's ajax methods that allow synchronization with server-side pagination in a rails app"
  s.license     = 'MIT'

  s.add_dependency 'railties', '>= 4.2'

  s.add_development_dependency 'rails', '>= 4.2'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'pg', '< 1.0'
  s.add_development_dependency 'mysql2'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'activerecord-oracle_enhanced-adapter'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'generator_spec'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_bot'
  s.add_development_dependency 'faker'
  s.add_development_dependency 'appraisal'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']
end
