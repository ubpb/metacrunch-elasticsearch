require "metacrunch"
require "elasticsearch"

module Metacrunch
  module Elasticsearch
    require_relative "./elasticsearch/cli"
    require_relative "./elasticsearch/index_creator"
    require_relative "./elasticsearch/indexer"
    require_relative "./elasticsearch/reader"
    require_relative "./elasticsearch/searcher"
    require_relative "./elasticsearch/uri"
    require_relative "./elasticsearch/writer"

    #
    # error class are inline to not clutter source files unnecessarily
    #
    class IndexAlreadyExistsError < StandardError; end
  end
end
