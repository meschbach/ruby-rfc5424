# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mee/rfc5424/version'

Gem::Specification.new do |spec|
  spec.name          = "mee-rfc5424"
  spec.version       = MEE::RFC5424::VERSION
  spec.authors       = ["Mark Eschbach"]
  spec.email         = ["meschbach@gmail.com"]
  spec.license       = "MIT"

  spec.summary       = %q{Utilities for dealing with RFC5424}
  spec.description   = %q{Initial scope is to produce loggers for TLS compliant to RFC5424.}
  spec.homepage      = "https://github.com/meschbach/ruby-rfc5424"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "syslog-parser", '0.1.0'
end
