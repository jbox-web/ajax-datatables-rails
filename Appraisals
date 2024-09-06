# frozen_string_literal: true

appraise 'rails_7.0.8' do # rubocop:disable Metrics/BlockLength
  gem 'rails', '7.0.8'

  install_if '-> { ENV["DB_ADAPTER"] == "sqlite3" }' do
    gem 'sqlite3', '~> 1.5.0'
  end

  install_if '-> { ENV["DB_ADAPTER"] == "mysql2" }' do
    gem 'mysql2'
  end

  install_if '-> { ENV["DB_ADAPTER"] == "trilogy" }' do
    gem 'activerecord-trilogy-adapter'
  end

  install_if '-> { ENV["DB_ADAPTER"] == "oracle_enhanced" }' do
    gem 'ruby-oci8'
    gem 'activerecord-oracle_enhanced-adapter', '~> 7.0.0'
  end

  install_if '-> { ENV["DB_ADAPTER"] == "postgis" }' do
    gem 'activerecord-postgis-adapter'
  end

  # Fix:
  # warning: logger was loaded from the standard library, but will no longer be part of the default gems since Ruby 3.5.0
  # Add logger to your Gemfile or gemspec.
  install_if '-> { Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.4.0") }' do
    gem 'base64'
    gem 'bigdecimal'
    gem 'benchmark'
    gem 'drb'
    gem 'logger'
    gem 'mutex_m'
    gem 'ostruct'
  end
end

appraise 'rails_7.1.0' do
  gem 'rails', '7.1.0'

  install_if '-> { ENV["DB_ADAPTER"] == "sqlite3" }' do
    gem 'sqlite3', '~> 1.5.0'
  end

  install_if '-> { ENV["DB_ADAPTER"] == "mysql2" }' do
    gem 'mysql2'
  end

  install_if '-> { ENV["DB_ADAPTER"] == "trilogy" }' do
    gem 'activerecord-trilogy-adapter'
  end

  install_if '-> { ENV["DB_ADAPTER"] == "oracle_enhanced" }' do
    gem 'ruby-oci8'
    gem 'activerecord-oracle_enhanced-adapter', git: 'https://github.com/rsim/oracle-enhanced.git'
  end

  install_if '-> { ENV["DB_ADAPTER"] == "postgis" }' do
    gem 'activerecord-postgis-adapter'
  end

  # Fix:
  # warning: logger was loaded from the standard library, but will no longer be part of the default gems since Ruby 3.5.0
  # Add logger to your Gemfile or gemspec.
  install_if '-> { Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.3.0") }' do
    gem 'logger'
    gem 'ostruct'
  end
end

appraise 'rails_7.2.0' do
  gem 'rails', '7.2.0'

  install_if '-> { ENV["DB_ADAPTER"] == "sqlite3" }' do
    gem 'sqlite3', '~> 1.5.0'
  end

  install_if '-> { ENV["DB_ADAPTER"] == "mysql2" }' do
    gem 'mysql2'
  end

  install_if '-> { ENV["DB_ADAPTER"] == "trilogy" }' do
    gem 'activerecord-trilogy-adapter'
  end

  install_if '-> { ENV["DB_ADAPTER"] == "oracle_enhanced" }' do
    gem 'ruby-oci8'
    gem 'activerecord-oracle_enhanced-adapter', git: 'https://github.com/rsim/oracle-enhanced.git'
  end

  install_if '-> { ENV["DB_ADAPTER"] == "postgis" }' do
    gem 'activerecord-postgis-adapter', git: 'https://github.com/rgeo/activerecord-postgis-adapter.git'
  end
end
