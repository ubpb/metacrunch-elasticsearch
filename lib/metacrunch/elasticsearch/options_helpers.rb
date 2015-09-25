require_relative "../elasticsearch"

module Metacrunch::Elasticsearch::OptionsHelpers
  def extract_options!(options, *keys)
    keys = keys
    .map do |_key|
      _key == :_client_options_ ? [:host, :hosts, :url, :urls] : _key
    end
    .flatten

    options
    .delete_if do |_key, _value|
      if keys.include?(_key)
        instance_variable_set("@#{_key}", _value)
        true # else if _value is falsy, the key does not get deleted
      end
    end
  end

  def normalize_options!(options)
    {
      index: options[:index],
      body: options.select { |_key, _| _key != :index }
    }
    .tap(&:compact!)
    .try do |_result|
      options.clear.merge!(_result)
    end
  end
end
