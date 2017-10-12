describe Metacrunch::Elasticsearch::Source do

  es_index = "metacrunch-elasticsearch-rspec"
  elasticsearch = Elasticsearch::Client.new(log: false)

  # Prepare some test data
  before do
    # Delete index if it exists
    if elasticsearch.indices.exists?(index: es_index)
      elasticsearch.indices.delete(index: es_index)
    end

    # Index 100 dummy users
    elasticsearch.bulk(body: 100.times.map { |i|
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
    })

    # Flush / commit index and make users immediately available to search
    elasticsearch.indices.flush(index: [es_index])
  end

  total_hits = 0

  let(:source) {
    Metacrunch::Elasticsearch::Source.new(
      elasticsearch,
      search_options: {
        size: 50,
        index: es_index,
        type: "users",
        body: {
          query: {
            match_all: {}
          }
        }
      },
      total_hits_callback: ->(th) {
        total_hits = th
      }
    )
  }

  context "when searched for all test data" do
    describe "#each" do
      it "is called 100 times" do
        results = source.each

        expect(results.count).to eq(100)
        expect(total_hits).to eq(100)
      end
    end
  end

end
