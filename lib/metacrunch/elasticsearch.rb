require "metacrunch"
require "elasticsearch"

module Metacrunch
  module Elasticsearch
    require_relative "./elasticsearch/uri"
    require_relative "./elasticsearch/reader"
    require_relative "./elasticsearch/writer"
  end
end
