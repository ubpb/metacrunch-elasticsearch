source "https://rubygems.org"

# Specify your gem's dependencies in your gemspec
gemspec

group :development do
  gem "bundler",         ">= 1.10"
  gem "rake"
  gem "rspec",           ">= 3.0.0",  "< 4.0.0"
  gem "simplecov",       ">= 0.8.0"
  gem "vcr",             ">= 2.9.0",  "< 3.0.0"
  gem "webmock",         ">= 1.19.0", "< 2.0.0"

  if !ENV["CI"]
    gem "hashdiff"
    gem "pry",                "~> 0.10.3"
    gem "pry-byebug",         "~> 3.3.0"
    gem "pry-rescue",         "~> 1.4.2"
    gem "pry-state",          "~> 0.1.7"
  end
end

group :test do
  gem "codeclimate-test-reporter", require: nil
end

gem "metacrunch", github: "ubpb/metacrunch", branch: :master
