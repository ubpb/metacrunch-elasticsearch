require "uri"
require_relative "../elasticsearch"


module Metacrunch
  module Elasticsearch
    class URI < URI::Generic

      DEFAULT_PORT = 9200

      def index
        splitted_path[0]
      end

      def type
        splitted_path[1]
      end

    private

      def splitted_path
        path.split("/").map(&:presence).compact
      end

    end
  end
end

module URI
  @@schemes['ELASTICSEARCH'] = Metacrunch::Elasticsearch::URI
end
