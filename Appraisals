# frozen_string_literal: true

RAILS_VERSIONS = {
  '4.0.13' => {
    'mysql2' => '~> 0.3.18',
    'activerecord-oracle_enhanced-adapter' => '~> 1.5.0'
  },
  '4.1.16' => {
    'mysql2' => '~> 0.3.18',
    'activerecord-oracle_enhanced-adapter' => '~> 1.5.0'
  },
  '4.2.10' => {
    'activerecord-oracle_enhanced-adapter' => '~> 1.6.0'
  },
  '5.0.6' => {
    'activerecord-oracle_enhanced-adapter' => '~> 1.7.0',
    'ruby-oci8' => ''
  },
  '5.1.5' => {
    'activerecord-oracle_enhanced-adapter' => '~> 1.8.0',
    'ruby-oci8' => ''
  }
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
