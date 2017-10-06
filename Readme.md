metacrunch-elasticsearch
========================

[![Gem Version](https://badge.fury.io/rb/metacrunch-elasticsearch.svg)](http://badge.fury.io/rb/metacrunch-elasticsearch)
[![Code Climate](https://codeclimate.com/github/ubpb/metacrunch-elasticsearch/badges/gpa.svg)](https://codeclimate.com/github/ubpb/metacrunch-elasticsearch)
[![Build Status](https://travis-ci.org/ubpb/metacrunch-elasticsearch.svg)](https://travis-ci.org/ubpb/metacrunch-elasticsearch)

This is the official [Elasticsearch](https://www.elastic.co) package for the [metacrunch ETL toolkit](https://github.com/ubpb/metacrunch).

Installation
------------

Include the gem in your `Gemfile`

```ruby
gem "metacrunch-elasticsearch", "~> 4.0.0"
```

and run `$ bundle install` to install it.

Or install it manually

```
$ gem install metacrunch-elasticsearch
```

Usage
-----

*Note: For working examples on how to use this package check out our [demo repository](https://github.com/ubpb/metacrunch-demo).*

### Source

The `Metacrunch::Elasticsearch::Source` class can be used to read data from Elasticsearch into a metacrunch job.

```ruby
# my_job.metacrunch

# Create a Elasticsearch connection 
elasticsearch = ::Elasticsearch::Client.new(...)

# Set the source
source Metacrunch::Elasticsearch::Source.new(elasticsearch, OPTIONS)
```

**Options**

* `:search_options`: A hash with search options (including your query) as described [here](https://github.com/elastic/elasticsearch-ruby/blob/master/elasticsearch-api/lib/elasticsearch/api/actions/search.rb). We have set some meaningful defaults though: `size: 100`, `scroll: 1m`, `sort: ["_doc"]`. Depending on your use-case it may be needed to modify `:size` and `:scroll` for optimal performance.
* `:total_hits_callback`: You can set a `Proc` that gets called with the total number of hits your query will match. Use can use this callback to setup a progress bar for example. Defaults to `nil`.

### Destination

The `Metacrunch::Elasticsearch::Destination` class can be used to write data from a metacrunch job to Elasticsearch.

To use it, the data that gets passed to the destination, must be in a proper format. Therefore you need to setup a transformation.

As `Metacrunch::Elasticsearch::Destination` utilizes the Elasticsearch bulk API, the expected format must match one of the available options for the `body`parameter described [here](https://github.com/elastic/elasticsearch-ruby/blob/master/elasticsearch-api/lib/elasticsearch/api/actions/bulk.rb). Please note that you can use the bulk API not only to index records. You can update or delete records as well.

```ruby
# my_job.metacrunch

# Transform data into a format that the destination can understand.
# In this example `data` is some hash.
transformation ->(data) do
  {
    index: {
      _index: "my-index",
      _type: "my-type",
      _id: data.delete(:id),
      data: data
    }
  }
end
```

It is not efficient to call Elasticsearch for every single record. Therefore we can use a transformation with a buffer, to create bulks of records. In this example we use a buffer size of 10. In production environments and depending on your data, larger buffers may be useful.

```ruby
# my_job.metacrunch

transformation ->(users) { users }, buffer_size: 10
```

If these transformations are in place you can now use the `Metacrunch::Elasticsearch::Destination` class as a destination.

```ruby
# my_job.metacrunch

# Write data into elasticsearch
destination Metacrunch::Elasticsearch::Destination.new(elasticsearch [, OPTIONS])
```

**Options**

* `:raise_on_result_errors`: If set to `true` an error is raised if one of the bulk operations return with an error. Defaults to `false`.
* `:result_callback`: You can set a `Proc` that gets called with the result from the bulk operation. Defaults to `nil`.
* `:bulk_options`: A hash of options for the Eleasticsearch bulk API as described [here](https://github.com/elastic/elasticsearch-ruby/blob/master/elasticsearch-api/lib/elasticsearch/api/actions/bulk.rb). Setting `body` here will be ignored. Defaults to `{}`.
