require "metacrunch/elasticsearch"

module Metacrunch
  class Elasticsearch::Destination

    DEFAULT_OPTIONS = {
      raise_on_result_errors: false,
      result_callback: nil,
      bulk_options: {}
    }

    def initialize(elasticsearch_client, options = {})
      @client = elasticsearch_client
      @options = DEFAULT_OPTIONS.deep_merge(options)
    end

    def write(data)
      return if data.blank?

      # Call elasticsearch bulk api
      bulk_options = @options[:bulk_options]
      bulk_options[:body] = data
      result = @client.bulk(bulk_options)

      # Raise an exception if one of the results produced an error and the user wants to know about it
      raise DestinationError.new(errors: result["errors"]) if result["errors"] && @options[:raise_on_result_errors]

      # if the user provided a callback proc, call it
      @options[:result_callback].call(result) if @options[:result_callback]&.respond_to?(:call)
    end

    def close
      # noop
    end

  end

  class Elasticsearch::DestinationError < StandardError

    attr_reader :errors

    def initialize(msg = nil, errors:)
      @errors = errors
    end

  end
end
