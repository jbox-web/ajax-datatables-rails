# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ajax-datatables-rails', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Joel Quenneville"]
  gem.email         = ["joel.quenneville@collegeplus.org"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "ajax-datatables-rails"
  gem.require_paths = ["lib"]
  gem.version       = AjaxDatatablesRails::VERSION

  gem.add_runtime_dependency 'jquery-datatables-rails', '~> 1.9.1'
end
