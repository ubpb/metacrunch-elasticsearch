describe Metacrunch::Elasticsearch::Indexer do
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
    @items = [
      { title: "Book1", id: "id1" },
      { title: "Book2", id: "id2" },
      { title: "Book3", id: "id3" }
    ]

    @pipeline = pipeline_factory
  end

  it "indexes the given items", :vcr do
    expect {
      described_class.new({
        id_accessor: :id,
        index: "some_index",
        type: "some_type",
        callbacks: {
          after_indexed: -> (item, response) {
            item[:id] = (response["create"] || response["index"])["_id"]
          }
        }
      }).call(@items, @pipeline)
    }.not_to raise_error
  end

  context "if id_accessor is a callable" do
    it "is called with the item and should return its id", :vcr do
      expect {
        described_class.new({
          id_accessor: -> (item) { item[:title] },
          index: "some_index",
          type: "some_type",
          callbacks: {
            after_indexed: -> (item, response) {
              raise if item[:title] != (response["create"] || response["index"])["_id"]
            }
          }
        }).call(@items, @pipeline)
      }.not_to raise_error
    end
  end
end
