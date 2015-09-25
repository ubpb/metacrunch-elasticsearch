if ENV["CODECLIMATE_REPO_TOKEN"]
  # report coverage only for latest mri ruby
  if RUBY_ENGINE == "ruby" && RUBY_VERSION >= "2.2.0"
    require "codeclimate-test-reporter"
    CodeClimate::TestReporter.start
  end
else
  require "simplecov"
  SimpleCov.start
end

require "metacrunch/elasticsearch"
require "vcr"
require "yaml"

begin
  require "hashdiff"
  require "pry"
rescue LoadError
end

RSpec.configure do |config|
  # begin --- rspec 3.1 generator
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  # end --- rspec 3.1 generator
end

VCR.configure do |c|
  c.allow_http_connections_when_no_cassette = true
  c.cassette_library_dir = "spec/cassettes"
  c.default_cassette_options = {
    match_requests_on: [:method, :uri, :query, :body],
    decode_compressed_response: true
  }
  c.hook_into :webmock

  # https://relishapp.com/vcr/vcr/v/2-9-3/docs/test-frameworks/usage-with-rspec-metadata
  c.configure_rspec_metadata!
end

def read_asset(path_to_file)
  File.read(File.expand_path(File.join(File.dirname(__FILE__), "assets", path_to_file)))
end
