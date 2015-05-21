require File.expand_path("../lib/metacrunch/elasticsearch/version", __FILE__)

Gem::Specification.new do |s|
  s.authors       = ["René Sprotte", "Michael Sievers"]
  s.email         = "r.sprotte@ub.uni-paderborn.de"
  s.summary       = %q{Elasticsearch tools for metacrunch}
  s.description   = s.summary
  s.homepage      = "http://github.com/ubpb/metacrunch-elasticsearch"
  s.licenses      = ["MIT"]

  s.files         = `git ls-files`.split($\)
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.name          = "metacrunch-elasticsearch"
  s.require_paths = ["lib"]
  s.version       = Metacrunch::Elasticsearch::VERSION

  s.required_ruby_version = ">= 2.2.0"

  s.add_dependency "elasticsearch", "~> 1.0"
  s.add_dependency "metacrunch",    "~> 2.1"
end
