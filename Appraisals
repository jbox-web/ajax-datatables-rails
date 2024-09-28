# frozen_string_literal: true

###############
# RAILS 7.0.8 #
###############

appraise 'rails_7.0.8_with_postgresql' do
  gem 'rails', '7.0.8'
  gem 'pg'

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

appraise 'rails_7.0.8_with_sqlite3' do
  gem 'rails', '7.0.8'
  gem 'sqlite3', '~> 1.5.0'
  remove_gem 'pg'

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

appraise 'rails_7.0.8_with_mysql2' do
  gem 'rails', '7.0.8'
  gem 'mysql2'
  remove_gem 'pg'

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

appraise 'rails_7.0.8_with_trilogy' do
  gem 'rails', '7.0.8'
  gem 'activerecord-trilogy-adapter'
  remove_gem 'pg'

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

appraise 'rails_7.0.8_with_oracle_enhanced' do
  gem 'rails', '7.0.8'
  gem 'ruby-oci8'
  gem 'activerecord-oracle_enhanced-adapter', '~> 7.0.0'
  remove_gem 'pg'

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

appraise 'rails_7.0.8_with_postgis' do
  gem 'rails', '7.0.8'
  gem 'pg'
  gem 'activerecord-postgis-adapter'

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

###############
# RAILS 7.1.0 #
###############

appraise 'rails_7.1.0_with_postgresql' do
  gem 'rails', '7.1.0'
  gem 'pg'
end

appraise 'rails_7.1.0_with_sqlite3' do
  gem 'rails', '7.1.0'
  gem 'sqlite3', '~> 1.5.0'
  remove_gem 'pg'
end

appraise 'rails_7.1.0_with_mysql2' do
  gem 'rails', '7.1.0'
  gem 'mysql2'
  remove_gem 'pg'
end

appraise 'rails_7.1.0_with_trilogy' do
  gem 'rails', '7.1.0'
  gem 'activerecord-trilogy-adapter'
  remove_gem 'pg'
end

appraise 'rails_7.1.0_with_oracle_enhanced' do
  gem 'rails', '7.1.0'
  gem 'ruby-oci8'
  gem 'activerecord-oracle_enhanced-adapter', git: 'https://github.com/rsim/oracle-enhanced.git'
  remove_gem 'pg'
end

appraise 'rails_7.1.0_with_postgis' do
  gem 'rails', '7.1.0'
  gem 'pg'
  gem 'activerecord-postgis-adapter'
end

###############
# RAILS 7.2.0 #
###############

appraise 'rails_7.2.0_with_postgresql' do
  gem 'rails', '7.2.0'
  gem 'pg'
end

appraise 'rails_7.2.0_with_sqlite3' do
  gem 'rails', '7.2.0'
  gem 'sqlite3', '~> 1.5.0'
  remove_gem 'pg'
end

appraise 'rails_7.2.0_with_mysql2' do
  gem 'rails', '7.2.0'
  gem 'mysql2'
  remove_gem 'pg'
end

appraise 'rails_7.2.0_with_trilogy' do
  gem 'rails', '7.2.0'
  gem 'activerecord-trilogy-adapter'
  remove_gem 'pg'
end

appraise 'rails_7.2.0_with_oracle_enhanced' do
  gem 'rails', '7.2.0'
  gem 'ruby-oci8'
  gem 'activerecord-oracle_enhanced-adapter', git: 'https://github.com/rsim/oracle-enhanced.git'
  remove_gem 'pg'
end

appraise 'rails_7.2.0_with_postgis' do
  gem 'rails', '7.2.0'
  gem 'pg'
  gem 'activerecord-postgis-adapter', git: 'https://github.com/rgeo/activerecord-postgis-adapter.git'
end
