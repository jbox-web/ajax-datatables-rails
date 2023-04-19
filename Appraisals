# frozen_string_literal: true

require 'yaml'

rails_versions = YAML.safe_load(File.read('appraisal.yml'))

rails_versions.each do |version, gems|
  appraise "rails_#{version}" do
    gem 'rails', version
    gems.each do |name, opts|
      if opts['install_if']
        install_if opts['install_if'] do
          if opts['version'].empty?
            gem name
          else
            gem name, opts['version']
          end
        end
      else
        if opts['version'].empty?
          gem name
        else
          gem name, opts['version']
        end
      end
    end
  end
end
