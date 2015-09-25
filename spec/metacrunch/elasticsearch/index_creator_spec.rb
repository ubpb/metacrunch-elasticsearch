describe Metacrunch::Elasticsearch::IndexCreator do
  def pipeline_factory
    Class.new do
      attr_accessor :logger

      def initialize
        @logger = Class.new(Logger) do
          def initialize(*args)
          end

          def add(*args, &block)
          end
        end.new
      end

      def terminate!;  @terminated = true; end
      def terminated?; !!@terminated;      end
    end
    .new
  end

  before(:example) do
    @items = []
    @pipeline = pipeline_factory
  end

  it "creates an index", :vcr do
    expect { described_class.new(index: "some_index").call(@items, @pipeline) }.not_to raise_error
  end

  context "if index already exists" do
    context "if options[:delete_existing_index] is not given" do
      it "raises an error", :vcr  do
        expect { described_class.new(index: "some_existing_index").call(@items, @pipeline) }.to raise_error(Metacrunch::Elasticsearch::IndexAlreadyExistsError)
      end
    end

    context "if options[:delete_existing_index] is true" do
      it "creates an index", :vcr  do
        processor = described_class.new({
          delete_existing_index: true,
          index: "some_existing_index"
        })

        expect { processor.call(@items, @pipeline) }.not_to raise_error
      end
    end

    context "if options[:delete_existing_index] is false" do
      it "does not create an index", :vcr do
        processor = described_class.new({
          delete_existing_index: false,
          index: "some_existing_index"
        })

        expect { processor.call(@items, @pipeline) }.not_to raise_error
      end
    end
  end

  context "if no index was given" do
    it "raises an error" do
      expect { described_class.new }.to raise_error(ArgumentError)
    end
  end

  context "if options[:default_mapping] is present" do
    it "uses it as the index default mapping", :vcr do
      processor = described_class.new({
        index: "some_index",
        default_mapping: {
          _timestamp: {
            enabled: true,
          }
        }
      })

      expect { processor.call(@items, @pipeline) }.not_to raise_error
    end
  end
end
