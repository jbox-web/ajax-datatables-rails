RAILS_VERSIONS = %w(
  4.1.15
  4.2.8
  5.0.2
  5.1.0
)

RAILS_VERSIONS.each do |version|
  appraise "rails_#{version}" do
    gem 'rails', version
    gem 'mysql2', '~> 0.3.18' if version == '4.1.15'
  end
end
