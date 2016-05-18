require "elasticsearch"
require_relative "../elasticsearch"
require_relative "./client_factory"
require_relative "./options_helpers"

class Metacrunch::Elasticsearch::Searcher
  include Enumerable
  include Metacrunch::Elasticsearch::ClientFactory
  include Metacrunch::Elasticsearch::OptionsHelpers

  DEFAULT_BODY = { query: { match_all: {} } }
  DEFAULT_SCAN_SIZE = 200 # per shard
  DEFAULT_SCROLL_EXPIRY_TIME = 10.minutes

  attr_accessor :bulk_size
  attr_accessor :index
  attr_accessor :scan_size
  attr_accessor :scroll_expiry_time
  attr_accessor :type

  def initialize(options = {})
    options.deep_symbolize_keys!
    extract_options!(options, :_client_options_, :bulk_size, :index, :scan_size, :scroll_expiry_time, :type)
    @body = options.presence || DEFAULT_BODY
  end

  def call(items = [])
    @docs_enumerator ||= @bulk_size ? each_slice(@bulk_size) : [each.to_a].to_enum
    items.concat(@docs_enumerator.next)
  end

  def each
    return enum_for(__method__) unless block_given?
    client = client_factory

    search_result = client.search({
      body: @body,
      index: @index,
      scroll: "#{@scroll_expiry_time || DEFAULT_SCROLL_EXPIRY_TIME}s",
      search_type: "scan",
      size: @scan_size || DEFAULT_SCAN_SIZE
    })

    while (
      search_result = client.scroll(
        scroll: "#{DEFAULT_SCROLL_EXPIRY_TIME}s",
        scroll_id: search_result["_scroll_id"]
      ) and # don't use &&, the semantic of and is important here
      search_result["hits"]["hits"].present?
    ) do
      search_result["hits"]["hits"].each do |_hit|
        yield _hit
      end
    end
  end
end
