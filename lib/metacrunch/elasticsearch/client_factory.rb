require "elasticsearch"
require_relative "../elasticsearch"

module Metacrunch::Elasticsearch::ClientFactory
  def client_factory
    client_options = {
      host: @host,
      hosts: @hosts,
      url: @url,
      urls: @urls
    }.compact

    Elasticsearch::Client.new(client_options)
  end
end
