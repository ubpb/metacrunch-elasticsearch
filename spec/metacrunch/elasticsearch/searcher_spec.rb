describe Metacrunch::Elasticsearch::Searcher do
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

  context "if no query parameters are given" do
    it "reads all documents from the given index", :vcr do
      processor = described_class.new(index: "some_index")

      expect { processor.call(@items, @pipeline) }.not_to raise_error
      expect(@items).not_to be_empty

      processor.call(@items, @pipeline) until @pipeline.terminated?
    end
  end
end
