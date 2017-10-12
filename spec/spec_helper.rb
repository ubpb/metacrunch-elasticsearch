require "pry" if !ENV["CI"]

require "simplecov"
SimpleCov.start do
  add_filter %r{^/spec/}
end

require "faker"
require "metacrunch/elasticsearch"

RSpec.configure do |config|
end
