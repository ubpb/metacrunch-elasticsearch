require "elasticsearch"
require_relative "../cli"

class Metacrunch::Elasticsearch::Cli::ListIndices < Metacrunch::Command
  def call
    puts indices
  end
  alias_method :perform, :call

  private

  def client
    @client ||= Elasticsearch::Client.new(url: @options[:url])
  end

  def indices
    client.cat.indices(h: "index", format: :json).map { |_element| _element["index"] }
  end
end
