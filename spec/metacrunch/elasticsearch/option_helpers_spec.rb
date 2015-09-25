require "metacrunch/elasticsearch/options_helpers"

describe Metacrunch::Elasticsearch::OptionsHelpers do
  let(:class_which_includes_module) do
    _described_class = described_class # scoping inside Class.new block

    Class.new do
      include _described_class
    end
  end

  let(:instance) do
    class_which_includes_module.new
  end

  describe "#extract_options!" do
    it "expands some special key names" do
      options = {
        foo: "bar",
        host: "some_host",
        hosts: ["some_host"],
        url: "some_url",
        urls: ["some_url"]
      }

      instance.extract_options!(options, :_client_options_)
      expect(options).to have_key(:foo)
      expect(options).not_to have_key(:host)
      expect(options).not_to have_key(:hosts)
      expect(options).not_to have_key(:url)
      expect(options).not_to have_key(:urls)
    end

    it "removes the given keys from the given hash" do
      options = { foo: "bar" }
      instance.extract_options!(options, :foo)
      expect(options).not_to have_key(:foo)
    end

    it "stores the value which corrsponds to the given key as an instance variable" do
      options = { foo: "bar" }
      instance.extract_options!(options, :foo)
      expect(instance.instance_variable_get(:@foo)).to be_present
    end
  end

  describe "#normalize_options!" do
    it "normalizes options into index/body form" do
      options = {
        index: "foo",
        some: {
          options: {
            value: "bar"
          }
        }
      }

      instance.normalize_options!(options)
      expect(options.keys).to eq([:index, :body])
    end
  end
end
