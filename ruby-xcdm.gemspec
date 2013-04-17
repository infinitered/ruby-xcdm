# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'xcdm/version'

Gem::Specification.new do |spec|
  spec.name          = "ruby-xcdm"
  spec.version       = XCDM::VERSION
  spec.authors       = ["Ken Miller"]
  spec.email         = ["ken@infinitered.com"]
  spec.description   = %q{Ruby DSL for creating Core Data Data Model files without XCode}
  spec.summary       = %q{Ruby XCDM}
  spec.homepage      = "https://github.com/infinitered/ruby-xcdm"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "builder", "~> 3.2"
  spec.add_dependency "activesupport", "~> 3.2"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "turn"
end
