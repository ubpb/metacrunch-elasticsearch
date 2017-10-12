describe Metacrunch::Elasticsearch::Destination do

  es_index = "metacrunch-elasticsearch-rspec"
  elasticsearch = Elasticsearch::Client.new(log: false)

  # Prepare some test data
  before do
    # Delete index if it exists
    if elasticsearch.indices.exists?(index: es_index)
      elasticsearch.indices.delete(index: es_index)
    end
  end

  result = nil

  let(:destination) {
    Metacrunch::Elasticsearch::Destination.new(
      elasticsearch,
      result_callback: ->(r) {
        result = r
      }
    )
  }

  let(:users) {
    100.times.map { |i|
      {
        index: {
          _index: es_index,
          _type: "users",
          _id: i+1,
          data: {
            name: Faker::Name.name,
            email: Faker::Internet.email
          }
        }
      }
    }
  }

  describe "#write" do
    it "writes the given data" do
      destination.write(users)

      expect(result).to_not be_nil
      expect(result["errors"]).to_not be_nil
      expect(result["errors"]).to eq(false)
    end
  end
end
