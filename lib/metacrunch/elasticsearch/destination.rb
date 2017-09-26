require "metacrunch/elasticsearch"

module Metacrunch
  class Elasticsearch::Destination

    DEFAULT_OPTIONS = {
      raise_on_result_errors: false,
      result_callback: nil
    }

    def initialize(elasticsearch_client, options = {})
      @client = elasticsearch_client
      @options = DEFAULT_OPTIONS.merge(options)
    end

    def write(data)
      return if data.blank?

      # Call elasticsearch bulk api
      result = @client.bulk(body: data.is_a?(Array) ? data : [data])

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
