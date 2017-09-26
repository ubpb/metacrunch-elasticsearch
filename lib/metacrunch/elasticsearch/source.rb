require "metacrunch/elasticsearch"

module Metacrunch
  class Elasticsearch::Source

    DEFAULT_OPTIONS = {
      size: 100,
      scroll: "1m",
      sort: ["_doc"]
    }

    def initialize(elasticsearch_client, options = {})
      @client = elasticsearch_client
      @options = DEFAULT_OPTIONS.merge(options)
    end

    def each(&block)
      return enum_for(__method__) unless block_given?

      # Perform search request and yield the first results if any
      result = @client.search(@options)
      yield_result(result, &block)

      # Scroll over the rest of result set and yield the results until the set is empty.
      while (
        # Note: semantic of 'and' is important here. Do not use '&&'.
        result = @client.scroll(scroll_id: result["_scroll_id"], scroll: @options[:scroll]) and result["hits"]["hits"].present?
      ) do
        yield_result(result, &block)
      end
    ensure
      # Clear scroll to free up resources.
      @client.clear_scroll(scroll_id: result["_scroll_id"]) if result
    end

  private

    def yield_result(result, &block)
      result["hits"]["hits"].each do |hit|
        yield(hit)
      end
    end

  end
end
