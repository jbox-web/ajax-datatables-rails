RAILS_VERSIONS = {
  '4.0.13' => {
    'mysql2' => '~> 0.3.18',
    'activerecord-oracle_enhanced-adapter' => '~> 1.5.0'
  },
  '4.1.15' => {
    'mysql2' => '~> 0.3.18',
    'activerecord-oracle_enhanced-adapter' => '~> 1.5.0'
  },
  '4.2.8' => {
    'activerecord-oracle_enhanced-adapter' => '~> 1.6.0'
  },
  '5.0.3' => {
    'activerecord-oracle_enhanced-adapter' => '~> 1.7.0',
    'ruby-oci8' => ''
  },
  '5.1.1' => {
    'activerecord-oracle_enhanced-adapter' => '~> 1.8.0',
    'ruby-oci8' => ''
  }
}

RAILS_VERSIONS.each do |version, gems|
  appraise "rails_#{version}" do
    gem 'rails', version
    gems.each do |name, version|
      if version.empty?
        gem name
      else
        gem name, version
      end
    end
  end
end
