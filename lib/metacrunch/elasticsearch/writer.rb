require "elasticsearch"
require_relative "../elasticsearch"

module Metacrunch
  module Elasticsearch
    class Writer

      def initialize(uri, log: false, bulk_size: 250)
        unless uri.starts_with?("elasticsearch://")
          raise ArgumentError, "URI must be an elasticsearch URI (elasticsearch://...)"
        end

        @uri       = URI(uri)
        @log       = log
        @bulk_size = bulk_size
        @buffer    = []
      end

      def write(data, options = {})
        id = data.delete(:id) || data.delete(:_id)
        raise ArgumentError, "Missing id. You must provide 'id' or '_id' as part of the data" unless id

        @buffer << {
          _index: @uri.index,
          _type: @uri.type,
          _id: id,
          data: data
        }

        flush if @bulk_size > 0 && @buffer.length >= @bulk_size

        true
      end

      def flush
        if @buffer.length > 0
          result = client.bulk(body: @buffer.inject([]){ |_body, _data| _body << { index: _data } })
          raise RuntimeError if result["errors"]
        end

        true
      ensure
        @buffer = []
      end

      def close
        flush
      end

    private

      def client
        @client ||= ::Elasticsearch::Client.new(host: @uri.host, port: @uri.port, log: @log)
      end

    end
  end
end
