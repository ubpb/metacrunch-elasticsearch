module Metacrunch
  module Elasticsearch
    module Cli
      require_relative "./cli/dump_metadata"
      require_relative "./cli/list_indices"
      #require_relative "./cli/reindex_command"
    end
  end
end

Metacrunch::Cli.setup("elasticsearch", "Commands for Elasticsearch") do |r|
  #
  #
  #
  r.register(Metacrunch::Elasticsearch::Cli::DumpMetadata) do |c|
    c.name  "dump_metadata"
    c.usage "dump_metadata"
    c.desc  "Dump index metadata"

    c.option :url,
      desc: "Elasticsearch url",
      type: :string,
      aliases: "-u",
      required: true
    c.option :format,
      desc: "Output format",
      type: :string,
      aliases: "-f",
      default: :yaml
    c.option :mappings_filename,
      desc: "Dump mappings",
      aliases: "-m"
    c.option :settings_filename,
      desc: "Dump settings",
      aliases: "-s",
      default: false
    c.option :index,
      desc: "Index name",
      aliases: "-i",
      required: true
    c.option :type,
      desc: "Type to dump mapping for",
      aliases: "-t",
      default: "_default_"

  end

  r.register(Metacrunch::Elasticsearch::Cli::ListIndices) do |c|
    c.name  "list_indices"
    c.usage "list_indices"
    c.desc  "List indices"

    c.option :url,
      desc: "Elasticsearch url",
      type: :string,
      aliases: "-u",
      required: true
  end
end
