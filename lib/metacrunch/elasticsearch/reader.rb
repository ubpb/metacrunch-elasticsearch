require "elasticsearch"
require_relative "../elasticsearch"

module Metacrunch
  module Elasticsearch
    class Reader

      DEFAULT_SCAN_SIZE          = 200
      DEFAULT_SCROLL_EXPIRY_TIME = 10.minutes


      def initialize(uri, body, log: false)
        unless uri.starts_with?("elasticsearch://")
          raise ArgumentError, "URI must be an elasticsearch URI (elasticsearch://...)"
        end

        @uri  = URI(uri)
        @body = body
        @log  = log
      end

      def each(&block)
        return enum_for(__method__) unless block_given?

        search_result = client.search({
          body: @body,
          index: @uri.index,
          type: @uri.type,
          scroll: "#{DEFAULT_SCROLL_EXPIRY_TIME}s",
          search_type: "scan",
          size: DEFAULT_SCAN_SIZE
        })

        while (
          search_result = client.scroll(
            scroll: "#{DEFAULT_SCROLL_EXPIRY_TIME}s",
            scroll_id: search_result["_scroll_id"]
          ) and # don't use &&, the semantic of 'and' is important here
          search_result["hits"]["hits"].present?
        ) do
          search_result["hits"]["hits"].each do |_hit|
            yield(_hit)
          end
        end
      end

    private

      def client
        @client ||= ::Elasticsearch::Client.new(host: @uri.host, port: @uri.port, log: @log)
      end

    end
  end
end
