# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'make_it_so/version'

Gem::Specification.new do |spec|
  spec.name          = "make_it_so"
  spec.version       = MakeItSo::VERSION
  spec.authors       = ["Dan Pickett"]
  spec.email         = ["dan.pickett@launchacademy.com"]
  spec.summary       = %q{An application generator for all things ruby}
  spec.description   = %q{Generate ruby gems, sinatra apps, and rails apps}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "thor"
  spec.add_dependency "railties", "~> 5.2"
  spec.add_dependency "activerecord", "~> 5.2"
  spec.add_dependency "json"

  spec.add_development_dependency "bundler", "~> 2.0.2"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "capybara"
end
