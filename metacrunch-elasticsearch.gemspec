# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "metacrunch/elasticsearch/version"

Gem::Specification.new do |spec|
  spec.name          = "metacrunch-elasticsearch"
  spec.version       = Metacrunch::Elasticsearch::VERSION
  spec.authors       = ["René Sprotte", "Michael Sievers"]
  spec.summary       = %q{Metacrunch elasticsearch package}
  spec.homepage      = "http://github.com/ubpb/metacrunch-elasticsearch"
  spec.licenses      = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport",   ">= 4.0.0"
  spec.add_dependency "elasticsearch",   "~> 1.0"
  spec.add_dependency "metacrunch",      "~> 2.1"
end

