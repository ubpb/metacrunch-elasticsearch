require "elasticsearch"
require_relative "../cli"

class Metacrunch::Elasticsearch::Cli::DumpMetadata < Metacrunch::Command
  def call
    [:mappings, :settings].each do |_element|
      _filename_option = "#{_element}_filename"

      if options[_filename_option].present?
        options["dump_#{_element}"] = true
      end

      if options[_filename_option] == _filename_option
        options.delete(_filename_option)
      end

      if options["dump_#{_element}"]
        if filename = options["#{_element}_filename"]
          File.write(filename, format(send(_element), format_from_filename(filename)))
        else
          puts send(_element)
        end
      end
    end

    if !options[:dump_mapping] && !options[:dump_settings]
      puts format(settings.merge(mappings), options[:format])
      
      if options[:format] == :yaml
        $stderr.puts <<-MESSAGE.strip_heredoc

          You have requested to dump settings and mapping into YAML. Please keep in mind
          that if you are trying to create an index with both, settings and mapping, this
          request has to be JSON formatted. Nevertheless you can create the index with YAML
          settings and put a YAML formatted mapping afterwards.

          https://github.com/elastic/elasticsearch/issues/1755

        MESSAGE
      end
    end
  end
  alias_method :perform, :call

  private

  def client
    @client ||= Elasticsearch::Client.new(url: options[:url])
  end

  def format(obj, format)
    if format.to_sym == :json
      JSON.pretty_generate(obj)
    elsif format.to_sym == :yaml
      YAML.dump(obj)
    else
      raise "Unknown output format!"
    end
  end

  def format_from_filename(filename)
    return nil if filename.blank?

    case File.extname(filename)
    when /json\Z/i then :json
    when /yml\Z|yaml\Z/i then :yaml
    end
  end
 
  def mappings
    client.indices.get_mapping(index: @options[:index], type: @options[:type]).try(:values).try(:first)
  end
 
  def settings
    client.indices.get_settings(index: @options[:index])
    .try(:values)
    .try(:first)
    .try(:tap) do |_obj|
      _obj["settings"]["index"].reject! do |_key, _|
        ["creation_date", "uuid", "version"].include?(_key)
      end
    end
  end
end
