require "metacrunch/elasticsearch"

module Metacrunch
  class Elasticsearch::Source

    DEFAULT_OPTIONS = {
      total_hits_callback: nil,
      search_options: {
        size: 100,
        scroll: "1m",
        sort: ["_doc"]
      }
    }

    def initialize(elasticsearch_client, options = {})
      @client = elasticsearch_client
      @options = DEFAULT_OPTIONS.deep_merge(options)
    end

    def each(&block)
      return enum_for(__method__) unless block_given?

      # Perform search request and yield the first results if any
      search_options = @options[:search_options]
      result = @client.search(search_options)
      call_total_hits_callback(result)
      yield_hits(result, &block)

      # Scroll over the rest of result set and yield the results until the set is empty.
      while (
        # Note: semantic of 'and' is important here. Do not use '&&'.
        result = @client.scroll(scroll_id: result["_scroll_id"], scroll: search_options[:scroll]) and result["hits"]["hits"].present?
      ) do
        yield_hits(result, &block)
      end
    ensure
      # Clear scroll to free up resources.
      @client.clear_scroll(scroll_id: result["_scroll_id"]) if result
    end

  private

    def call_total_hits_callback(result)
      if @options[:total_hits_callback]&.respond_to?(:call) && total = result.dig("hits", "total", "value")
        @options[:total_hits_callback].call(total)
      end
    end

    def yield_hits(result, &block)
      result["hits"]["hits"].each do |hit|
        yield(hit)
      end
    end

  end
end
