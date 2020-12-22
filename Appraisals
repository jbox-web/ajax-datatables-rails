# frozen_string_literal: true

RAILS_VERSIONS = {
  '5.2.4' => {
    'activerecord-oracle_enhanced-adapter' => '~> 5.2.0',
    'sqlite3' => '~> 1.3.0',
    'mysql2' => '',
    'ruby-oci8' => '',
  },
  '6.0.3' => {
    'activerecord-oracle_enhanced-adapter' => '~> 6.0.0',
    'sqlite3' => '~> 1.4.0',
    'mysql2' => '',
    'ruby-oci8' => '',
  },
  '6.1.0' => {
    'activerecord-oracle_enhanced-adapter' => '~> 6.1.0',
    'sqlite3' => '~> 1.4.0',
    'mysql2' => '',
    'ruby-oci8' => '',
  },
}.freeze

RAILS_VERSIONS.each do |version, gems|
  appraise "rails_#{version}" do
    gem 'rails', version
    gems.each do |name, gem_version|
      if gem_version.empty?
        gem name
      else
        gem name, gem_version
      end
    end
  end
end
