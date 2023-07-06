# frozen_string_literal: true

RSpec.describe InstaJsonParser do
  it "has a version number" do
    expect(InstaJsonParser::VERSION).not_to be nil
  end
end

RSpec.describe InstaJsonParser::Parser do
  describe "#perform" do

    before(:all) do
      FileUtils.rm_rf('./spec/tmp/batch_output') if File.directory?('./spec/tmp/batch_output')
    end

    it "creates ten json files given 1000 entries" do
      a = described_class.new("./spec/fixtures/entry-many.json", output_dir: './spec/tmp/batch_output')
      a.perform
      expect(Dir["./spec/tmp/batch_output/**/*.json"].length).to eq 10
    end
  end
end
