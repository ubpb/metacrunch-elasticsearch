require "metacrunch/elasticsearch"

module Metacrunch
  class Elasticsearch::Destination

    DEFAULT_OPTIONS = {
      raise_on_result_errors: false, # deprecated
      result_callback: nil,
      bulk_options: {}
    }

    def initialize(elasticsearch_client, options = {})
      @client = elasticsearch_client
      @options = DEFAULT_OPTIONS.deep_merge(options)

      @deprecator = ActiveSupport::Deprecation.new("5.0.0", "metacrunch-elasticsearch")
      if @options[:raise_on_result_errors]
        @deprecator.deprecation_warning("Option :raise_on_result_errors")
      end
    end

    def write(data)
      return if data.blank?

      # Call elasticsearch bulk api
      bulk_options = @options[:bulk_options]
      bulk_options[:body] = data
      result = @client.bulk(bulk_options)

      # if the user provided a callback proc, call it
      @options[:result_callback].call(result) if @options[:result_callback]&.respond_to?(:call)
    end

    def close
      # noop
    end

  end
end
