# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ruby_clone/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Frederico Benevides"]
  gem.email         = ["fredbene@gmail.com"]
  gem.description   = %q{Ruby clone is a command line tool to work with Rsync using DSL!}
  gem.summary       = %q{Ruby_clone is high level script of Rsync. Use Ruby DSL to work with RSync! }
  gem.homepage      = "http://github.com/fredericobenevides/ruby_clone"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "ruby_clone"
  gem.require_paths = ["lib"]
  gem.version       = RubyClone::VERSION

  gem.add_development_dependency "guard", "~> 1.3.2"
  gem.add_development_dependency "guard-rspec", "~> 1.2.1"
  gem.add_development_dependency "rspec", "~> 2.11.0"
end
