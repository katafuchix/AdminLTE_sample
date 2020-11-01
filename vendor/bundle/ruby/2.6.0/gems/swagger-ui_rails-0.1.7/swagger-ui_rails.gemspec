# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'swagger-ui_rails/version'

Gem::Specification.new do |gem|
  gem.name          = "swagger-ui_rails"
  gem.version       = Swagger::UiRails::VERSION
  gem.authors       = ["Stjepan Hadjic"]
  gem.email         = ["Stjepan.hadjic@infinum.hr"]
  gem.description   = %q{A gem to add swagger-ui to rails asset pipeline}
  gem.summary       = %q{Add swagger-ui to your rails app easily}
  gem.homepage      = "https://github.com/d4be4st/swagger-ui_rails"
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "bundler", "~> 1.3"
  gem.add_development_dependency "rake"
end
