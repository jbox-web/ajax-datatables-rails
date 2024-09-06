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
    'homepage_uri'          => 'https://github.com/jbox-web/ajax-datatables-rails',
    'changelog_uri'         => 'https://github.com/jbox-web/ajax-datatables-rails/blob/master/CHANGELOG.md',
    'source_code_uri'       => 'https://github.com/jbox-web/ajax-datatables-rails',
    'bug_tracker_uri'       => 'https://github.com/jbox-web/ajax-datatables-rails/issues',
    'rubygems_mfa_required' => 'true',
  }

  s.required_ruby_version = '>= 3.0.0'

  s.files = `git ls-files`.split("\n")

  s.add_dependency 'rails', '>= 7.0'
  s.add_dependency 'zeitwerk'
end
