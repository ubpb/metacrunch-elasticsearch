require "elasticsearch"
require_relative "../elasticsearch"
require_relative "./client_factory"
require_relative "./options_helpers"

class Metacrunch::Elasticsearch::Indexer
  include Metacrunch::Elasticsearch::ClientFactory
  include Metacrunch::Elasticsearch::OptionsHelpers

  attr_accessor :bulk_size
  attr_accessor :callbacks
  attr_accessor :id_accessor
  attr_accessor :index
  attr_accessor :logger
  attr_accessor :type

  def initialize(options = {})
    (@client_args = options).deep_symbolize_keys!
    extract_options!(@client_args, :_client_options_, :bulk_size, :callbacks, :id_accessor, :index, :logger, :type)
    raise ArgumentError.new("You have to supply an index name!") if @index.blank?
  end

  def call(items = [])
    logger = @logger

    if (slice_size = @bulk_size || items.length) > 0
      client = client_factory

      items.each_slice(slice_size) do |_item_slice|
        # bodies is an array to allow slicing in case of HTTP content length exceed
        bodies = [_item_slice.inject([]) { |_memo, _item| _memo.concat bulk_item_factory(_item) }]

        bulk_responses =
        begin
          bodies.map do |_body|
            client.bulk body: _body
          end
        rescue
          logger.info "Bulk index failed. Decreasing bulk size temporary and trying again." if logger

          bodies = bodies.inject([]) do |_memo, _body|
            # Since we have to work with the bulk request body instead if the original items
            # the bodys length has to be a multiple of 2 in any case. .fdiv(2).fdiv(2).ceil * 2
            # ensures this. Example 3698.fdiv(2).fdiv(2).fdiv(2).ceil * 2 == 1850
            _memo.concat(_body.each_slice(_body.length.fdiv(2).fdiv(2).ceil * 2).to_a)
          end

          retry
        end

        bulk_responses.each do |_bulk_response|
          log_items_indexed(logger, _bulk_response["items"].length, client) if logger

          if after_indexed_callback = (@callbacks || {})[:after_indexed]
            _item_slice.zip(_bulk_response["items"]).each do |_item, _item_response|
              after_indexed_callback.call(_item, _item_response)
            end
          end
        end
      end
    end
  end

  private

  def bulk_item_factory(item)
    [
      { index: { _index: @index, _type: @type, _id: id(item) }.compact },
      item.to_h
    ]
  end

  def id(item)
    if @id_accessor
      if @id_accessor.respond_to?(:call)
        @id_accessor.call(item)
      else
        item[@id_accessor]
      end
    end
  end

  def log_items_indexed(logger, amount, client)
    paths = client.transport.hosts.map do |_host|
      "#{_host[:host]}:#{_host[:port]}/#{@index}/#{@type}"
    end

    logger.info("Indexed #{amount} items to #{paths}")
  end
end
