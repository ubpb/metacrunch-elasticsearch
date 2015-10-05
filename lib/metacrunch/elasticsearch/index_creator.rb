require "elasticsearch"
require "metacrunch/processor"
require_relative "../elasticsearch"
require_relative "./client_factory"
require_relative "./options_helpers"

class Metacrunch::Elasticsearch::IndexCreator < Metacrunch::Processor
  include Metacrunch::Elasticsearch::ClientFactory
  include Metacrunch::Elasticsearch::OptionsHelpers

  attr_accessor :default_mapping
  attr_accessor :delete_existing_index
  attr_accessor :logger

  def initialize(options = {})
    (@client_args = options).deep_symbolize_keys!
    extract_options!(@client_args, :_client_options_, :default_mapping, :delete_existing_index, :logger)
    raise ArgumentError.new("You have to supply an index name!") if @client_args[:index].blank?
  end

  def call(items = [], pipeline = nil)
    client = client_factory
    logger = pipeline.try(:logger) || @logger

    if client.indices.exists?(@client_args)
      if @delete_existing_index == true
        client.indices.delete(@client_args)
        log_index_deleted(logger, @client_args[:index], client) if logger
      elsif @delete_existing_index == false
        return
      else
        raise Metacrunch::Elasticsearch::IndexAlreadyExistsError
      end
    end

    client.indices.create(@client_args)
    log_index_created(logger, @client_args[:index], client) if logger

    if @default_mapping
      client.indices.put_mapping(
        @client_args.merge(
          type: "_default_",
          body: {
            _default_: @default_mapping
          }
        )
      )
    end
  end

  private

  def log_index_created(logger, index, client)
    paths = client.transport.hosts.map do |_host|
      "#{_host[:host]}:#{_host[:port]}"
    end

    logger.info("Index #{index} created at #{paths}")
  end

  def log_index_deleted(logger, index, client)
    paths = client.transport.hosts.map do |_host|
      "#{_host[:host]}:#{_host[:port]}"
    end

    logger.info("Index #{index} deleted at #{paths}")
  end
end
