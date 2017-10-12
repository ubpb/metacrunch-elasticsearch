require "active_support"
require "active_support/core_ext"
require "elasticsearch"

module Metacrunch
  module Elasticsearch
    require_relative "elasticsearch/destination"
    require_relative "elasticsearch/source"
  end
end
